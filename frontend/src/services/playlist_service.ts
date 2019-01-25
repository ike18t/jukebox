import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Playlist } from '../models/playlist';

@Injectable()
export class PlaylistService {
  constructor(private http: Http) {}

  create(playlistUrl: string) {
    this.http.post('/playlists', { playlist_url: playlistUrl }).subscribe();
  }

  enable(playlist: Playlist) {
    this.http.put(`/playlists/${playlist.id}/enable`, {}).subscribe();
  }

  disable(playlist: Playlist) {
    this.http.put(`/playlists/${playlist.id}/disable`, {}).subscribe();
  }
}
