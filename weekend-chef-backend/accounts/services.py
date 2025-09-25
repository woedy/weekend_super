from __future__ import annotations

import logging
from datetime import timedelta
import secrets
import string
from typing import Optional

from django.conf import settings
from django.core.mail import send_mail
from django.utils import timezone

from .models import VerificationToken, User

logger = logging.getLogger(__name__)


def _generate_code(length: int = 6) -> str:
    alphabet = string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))


def issue_token(user: User, purpose: VerificationToken.Purpose, *, destination: Optional[str] = None,
                expires_in: timedelta = timedelta(minutes=10)) -> VerificationToken:
    VerificationToken.objects.filter(user=user, purpose=purpose, consumed_at__isnull=True).update(consumed_at=timezone.now())
    token = VerificationToken.objects.create(
        user=user,
        purpose=purpose,
        code=_generate_code(),
        destination=destination or '',
        expires_at=timezone.now() + expires_in,
    )
    _deliver_token(token)
    return token


def _deliver_token(token: VerificationToken) -> None:
    if token.purpose == VerificationToken.Purpose.EMAIL:
        subject = "Verify your Weekend Chef email"
        message = f"Your verification code is {token.code}. It expires in 10 minutes."
        recipient = token.destination or token.user.email
        if recipient:
            try:
                send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [recipient], fail_silently=True)
            except Exception:  # pragma: no cover - log but continue
                logger.exception("Failed to send verification email")
    elif token.purpose == VerificationToken.Purpose.PHONE:
        logger.info("Dispatching SMS token %s to %s", token.code, token.destination or token.user.phone)
    elif token.purpose == VerificationToken.Purpose.PASSWORD_RESET:
        subject = "Reset your Weekend Chef password"
        message = f"Enter {token.code} in the app to continue."
        recipient = token.destination or token.user.email
        if recipient:
            try:
                send_mail(subject, message, settings.DEFAULT_FROM_EMAIL, [recipient], fail_silently=True)
            except Exception:  # pragma: no cover
                logger.exception("Failed to send password reset email")


def validate_token(user: User, code: str, purpose: VerificationToken.Purpose) -> VerificationToken:
    token = VerificationToken.objects.filter(user=user, purpose=purpose, code=code).order_by('-created_at').first()
    if not token:
        raise VerificationToken.DoesNotExist()
    if token.is_expired:
        raise ValueError("Token expired")
    if token.is_consumed:
        raise ValueError("Token already used")
    return token
