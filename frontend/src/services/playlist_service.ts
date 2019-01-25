import { Injectable } from '@angular/core';
import { Http } from '@angular/http';
import { Playlist } from '../models/playlist';

@Injectable()
export class PlaylistService {
  constructor(private http: Http) {}

  enablePlaylist(playlist: Playlist) {
    const playlistId = encodeURI(playlist.id);
    this.http.put(`/playlists/${playlistId}/enable`, {}).subscribe();
  }

  disablePlaylist(playlist: Playlist) {
    const playlistId = encodeURI(playlist.id);
    this.http.put(`/playlists/${playlistId}/disable`, {}).subscribe();
  }
}
