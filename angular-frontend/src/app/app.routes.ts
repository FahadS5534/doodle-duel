import { Routes } from '@angular/router';
import { authGuard, guestOrAuthGuard } from './core/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    pathMatch: 'full',
    redirectTo: 'home'
  },
  {
    path: 'welcome',
    canActivate: [guestOrAuthGuard],
    loadComponent: () => import('./features/welcome/welcome.component').then(m => m.WelcomeComponent)
  },
  {
    path: 'login',
    canActivate: [guestOrAuthGuard],
    loadComponent: () => import('./features/auth/login/login.component').then(m => m.LoginComponent)
  },
  {
    path: 'register',
    canActivate: [guestOrAuthGuard],
    loadComponent: () => import('./features/auth/register/register.component').then(m => m.RegisterComponent)
  },
  {
    path: 'home',
    canActivate: [authGuard],
    loadComponent: () => import('./features/home/home.component').then(m => m.HomeComponent)
  },
  {
    path: 'discover',
    canActivate: [authGuard],
    loadComponent: () => import('./features/rooms/discover/discover.component').then(m => m.DiscoverComponent)
  },
  {
    path: 'lobby/:roomId',
    canActivate: [authGuard],
    loadComponent: () => import('./features/lobby/waiting-lobby.component').then(m => m.WaitingLobbyComponent)
  },
  {
    path: 'game/:roomId',
    canActivate: [authGuard],
    loadComponent: () => import('./features/gameplay/gameplay.component').then(m => m.GameplayComponent)
  },
  {
    path: 'sketchpad',
    loadComponent: () => import('./features/sketchpad/sketchpad.component').then(m => m.SketchpadComponent)
  },
  {
    path: 'leaderboard',
    loadComponent: () => import('./features/leaderboard/leaderboard.component').then(m => m.LeaderboardComponent)
  },
  {
    path: 'profile',
    canActivate: [authGuard],
    loadComponent: () => import('./features/profile/profile.component').then(m => m.ProfileComponent)
  },
  {
    path: '**',
    redirectTo: 'home'
  }
];
