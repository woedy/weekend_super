from django.contrib.auth import login
from rest_framework import generics, status
from rest_framework.authtoken.models import Token
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response

from accounts.api.permissions import RolePermission
from accounts.api.v2.serializers import (
    LoginSerializer,
    ProfileSerializer,
    RegistrationSerializer,
    VerificationRequestSerializer,
    VerificationSerializer,
)
from accounts.models import VerificationToken
from accounts.services import issue_token


class RegistrationView(generics.CreateAPIView):
    serializer_class = RegistrationSerializer
    permission_classes = [AllowAny]


class LoginView(generics.GenericAPIView):
    serializer_class = LoginSerializer
    permission_classes = [AllowAny]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.validated_data["user"]
        login(request, user)
        token, _ = Token.objects.get_or_create(user=user)
        return Response({"token": token.key, "user": ProfileSerializer(user).data})


class ProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = ProfileSerializer
    permission_classes = [IsAuthenticated]

    def get_object(self):
        return self.request.user


class VerificationRequestView(generics.CreateAPIView):
    serializer_class = VerificationRequestSerializer
    permission_classes = [IsAuthenticated]


class VerificationView(generics.CreateAPIView):
    serializer_class = VerificationSerializer
    permission_classes = [IsAuthenticated]

    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        return Response(ProfileSerializer(user).data, status=status.HTTP_200_OK)


class ResendPhoneVerificationView(generics.GenericAPIView):
    serializer_class = VerificationRequestSerializer
    permission_classes = [IsAuthenticated, RolePermission]
    required_roles = ["Chef", "Client", "Dispatch"]

    def post(self, request, *args, **kwargs):
        serializer = self.get_serializer(data={"purpose": VerificationToken.Purpose.PHONE})
        serializer.is_valid(raise_exception=True)
        issue_token(request.user, VerificationToken.Purpose.PHONE, destination=request.user.phone)
        return Response(status=status.HTTP_204_NO_CONTENT)
