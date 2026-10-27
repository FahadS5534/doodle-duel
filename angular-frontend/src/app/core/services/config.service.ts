import { Injectable, signal } from '@angular/core';

@Injectable({
  providedIn: 'root'
})
export class ConfigService {
  // Defaults to production Render deployment
  private readonly defaultApiUrl = 'https://doodle-duel-9wbf.onrender.com/api/v1';
  private readonly defaultWsUrl = 'wss://doodle-duel-9wbf.onrender.com/ws';

  readonly apiUrl = signal<string>(
    localStorage.getItem('doodle_api_url') || this.defaultApiUrl
  );
  readonly wsUrl = signal<string>(
    localStorage.getItem('doodle_ws_url') || this.defaultWsUrl
  );

  setEndpoints(api?: string, ws?: string): void {
    if (api) {
      this.apiUrl.set(api);
      localStorage.setItem('doodle_api_url', api);
    }
    if (ws) {
      this.wsUrl.set(ws);
      localStorage.setItem('doodle_ws_url', ws);
    }
  }

  resetEndpoints(): void {
    this.apiUrl.set(this.defaultApiUrl);
    this.wsUrl.set(this.defaultWsUrl);
    localStorage.removeItem('doodle_api_url');
    localStorage.removeItem('doodle_ws_url');
  }

  isUsingLocal(): boolean {
    return this.apiUrl().includes('localhost');
  }

  toggleLocalEndpoints(): void {
    if (this.isUsingLocal()) {
      this.resetEndpoints();
    } else {
      this.setEndpoints('http://localhost:8080/api/v1', 'ws://localhost:8080/ws');
    }
  }
}
