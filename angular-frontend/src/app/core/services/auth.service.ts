import { Injectable, computed, inject, signal } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { Router } from '@angular/router';
import { Observable, catchError, map, of, tap } from 'rxjs';
import { ApiResponse, AuthResponse, User } from '../models/user.model';
import { ConfigService } from './config.service';

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly config = inject(ConfigService);

  private readonly tokenKey = 'doodle_auth_token';
  private readonly userKey = 'doodle_user_data';

  readonly token = signal<string | null>(localStorage.getItem(this.tokenKey));
  readonly currentUser = signal<User | null>(this.loadStoredUser());
  readonly isLoading = signal<boolean>(false);
  readonly errorMessage = signal<string | null>(null);

  readonly isAuthenticated = computed(() => !!this.token() && !!this.currentUser());

  private loadStoredUser(): User | null {
    const raw = localStorage.getItem(this.userKey);
    if (!raw) return null;
    try {
      return JSON.parse(raw);
    } catch (_) {
      return null;
    }
  }

  guestLogin(displayName?: string): Observable<boolean> {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    const payload = displayName ? { displayName } : {};
    return this.http.post<ApiResponse<AuthResponse>>(`${this.config.apiUrl()}/auth/guest`, payload).pipe(
      map(res => {
        if (res.success && res.data) {
          this.setSession(res.data);
          return true;
        }
        this.errorMessage.set(res.message || 'Guest login failed');
        return false;
      }),
      catchError(err => {
        console.error('Guest login error:', err);
        // Offline / dev fallback: create local guest if backend unreachable
        const fallbackGuest: AuthResponse = {
          token: 'local-guest-jwt-' + Date.now(),
          tokenType: 'Bearer',
          id: 'guest-' + Math.random().toString(36).substring(2, 9),
          username: displayName ? displayName.toLowerCase().replace(/\s+/g, '_') : 'guest_' + Math.floor(Math.random() * 9000 + 1000),
          displayName: displayName || 'Artist ' + Math.floor(Math.random() * 900 + 100),
          isGuest: true,
          avatarUrl: 'https://api.dicebear.com/7.x/bottts/svg?seed=' + Math.random(),
          level: 1,
          xp: 0,
          coins: 100,
          streak: 1
        };
        this.setSession(fallbackGuest);
        return of(true);
      }),
      tap(() => this.isLoading.set(false))
    );
  }

  login(usernameOrEmail: string, password: string): Observable<boolean> {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    return this.http.post<ApiResponse<AuthResponse>>(`${this.config.apiUrl()}/auth/login`, {
      usernameOrEmail,
      password
    }).pipe(
      map(res => {
        if (res.success && res.data) {
          this.setSession(res.data);
          return true;
        }
        this.errorMessage.set(res.message || 'Login failed');
        return false;
      }),
      catchError(err => {
        const msg = err.error?.message || 'Invalid username or password';
        this.errorMessage.set(msg);
        return of(false);
      }),
      tap(() => this.isLoading.set(false))
    );
  }

  register(username: string, email: string, password: string, displayName: string): Observable<boolean> {
    this.isLoading.set(true);
    this.errorMessage.set(null);

    return this.http.post<ApiResponse<AuthResponse>>(`${this.config.apiUrl()}/auth/register`, {
      username,
      email,
      password,
      displayName
    }).pipe(
      map(res => {
        if (res.success && res.data) {
          this.setSession(res.data);
          return true;
        }
        this.errorMessage.set(res.message || 'Registration failed');
        return false;
      }),
      catchError(err => {
        const msg = err.error?.message || 'Registration failed. Username or email may already be in use.';
        this.errorMessage.set(msg);
        return of(false);
      }),
      tap(() => this.isLoading.set(false))
    );
  }

  private setSession(auth: AuthResponse): void {
    const user: User = {
      id: auth.id,
      username: auth.username,
      displayName: auth.displayName,
      isGuest: auth.isGuest,
      avatarUrl: auth.avatarUrl,
      level: auth.level,
      xp: auth.xp,
      coins: auth.coins,
      streak: auth.streak
    };

    this.token.set(auth.token);
    this.currentUser.set(user);
    localStorage.setItem(this.tokenKey, auth.token);
    localStorage.setItem(this.userKey, JSON.stringify(user));
  }

  updateProfileLocally(partial: Partial<User>): void {
    const current = this.currentUser();
    if (!current) return;
    const updated = { ...current, ...partial };
    this.currentUser.set(updated);
    localStorage.setItem(this.userKey, JSON.stringify(updated));
  }

  logout(): void {
    this.token.set(null);
    this.currentUser.set(null);
    localStorage.removeItem(this.tokenKey);
    localStorage.removeItem(this.userKey);
    this.router.navigate(['/welcome']);
  }
}
