import { inject } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { AuthService } from '../services/auth.service';

export const authGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  if (authService.isAuthenticated()) {
    return true;
  }

  router.navigate(['/welcome']);
  return false;
};

export const guestOrAuthGuard: CanActivateFn = () => {
  const authService = inject(AuthService);
  const router = inject(Router);

  // If already logged in, redirect /welcome or /login to /home
  if (authService.isAuthenticated()) {
    router.navigate(['/home']);
    return false;
  }

  return true;
};
