from __future__ import annotations

from django.contrib.auth import authenticate, get_user_model
from django.utils.translation import gettext_lazy as _
from rest_framework import serializers

from accounts.models import USER_TYPE, VerificationToken
from accounts.services import issue_token, validate_token

User = get_user_model()


class RegistrationSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, style={"input_type": "password"})
    role = serializers.ChoiceField(choices=[choice for choice in USER_TYPE if choice[0] != 'Admin'], write_only=True)

    class Meta:
        model = User
        fields = ["email", "password", "first_name", "last_name", "phone", "role"]
        extra_kwargs = {"role": {"write_only": True}}

    def create(self, validated_data):
        role = validated_data.pop("role")
        password = validated_data.pop("password")
        user = User.objects.create(**validated_data)
        user.user_type = role
        user.set_password(password)
        user.save()
        if user.email:
            issue_token(user, VerificationToken.Purpose.EMAIL, destination=user.email)
        if user.phone:
            issue_token(user, VerificationToken.Purpose.PHONE, destination=user.phone)
        return user


class ProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = [
            "user_id",
            "email",
            "first_name",
            "last_name",
            "phone",
            "gender",
            "dob",
            "language",
            "about_me",
            "location_name",
            "lat",
            "lng",
            "user_type",
            "email_verified",
            "phone_verified",
        ]
        read_only_fields = ["user_id", "user_type", "email_verified", "phone_verified"]


class LoginSerializer(serializers.Serializer):
    email = serializers.EmailField()
    password = serializers.CharField(write_only=True, style={"input_type": "password"})

    def validate(self, attrs):
        email = attrs.get("email")
        password = attrs.get("password")
        user = authenticate(username=email, password=password)
        if not user:
            raise serializers.ValidationError(_("Invalid email/password combination."))
        attrs["user"] = user
        return attrs


class VerificationRequestSerializer(serializers.Serializer):
    purpose = serializers.ChoiceField(choices=VerificationToken.Purpose.choices)

    def validate(self, attrs):
        user = self.context["request"].user
        purpose = attrs["purpose"]
        if purpose == VerificationToken.Purpose.EMAIL and user.email_verified:
            raise serializers.ValidationError({"purpose": _("Email already verified.")})
        if purpose == VerificationToken.Purpose.PHONE and user.phone_verified:
            raise serializers.ValidationError({"purpose": _("Phone already verified.")})
        return attrs

    def create(self, validated_data):
        user = self.context["request"].user
        purpose = validated_data["purpose"]
        destination = user.email if purpose == VerificationToken.Purpose.EMAIL else user.phone
        return issue_token(user, purpose, destination=destination)


class VerificationSerializer(serializers.Serializer):
    purpose = serializers.ChoiceField(choices=VerificationToken.Purpose.choices)
    code = serializers.CharField(max_length=8)

    default_error_messages = {
        "expired": _("Verification code has expired."),
        "consumed": _("Verification code already used."),
        "invalid": _("Could not find a matching verification code."),
    }

    def validate(self, attrs):
        user = self.context["request"].user
        purpose = attrs["purpose"]
        code = attrs["code"]
        try:
            token = validate_token(user, code, purpose)
        except VerificationToken.DoesNotExist:
            self.fail("invalid")
        except ValueError as exc:
            if "expired" in str(exc).lower():
                self.fail("expired")
            self.fail("consumed")
        attrs["token"] = token
        return attrs

    def create(self, validated_data):
        user = self.context["request"].user
        token = validated_data["token"]
        token.mark_consumed()
        if token.purpose == VerificationToken.Purpose.EMAIL:
            user.email_verified = True
        elif token.purpose == VerificationToken.Purpose.PHONE:
            user.phone_verified = True
        user.save(update_fields=["email_verified", "phone_verified"])
        return user
