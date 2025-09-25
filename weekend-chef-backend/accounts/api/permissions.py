from rest_framework.permissions import BasePermission


class RolePermission(BasePermission):
    message = "You do not have permission to perform this action."

    def has_permission(self, request, view):
        required_roles = getattr(view, "required_roles", None)
        if not required_roles:
            return request.user and request.user.is_authenticated
        return request.user and request.user.is_authenticated and request.user.user_type in required_roles

    def has_object_permission(self, request, view, obj):
        return self.has_permission(request, view)


class IsEmailVerified(BasePermission):
    message = "Email address has not been verified."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.email_verified)


class IsPhoneVerified(BasePermission):
    message = "Phone number has not been verified."

    def has_permission(self, request, view):
        return bool(request.user and request.user.is_authenticated and request.user.phone_verified)
