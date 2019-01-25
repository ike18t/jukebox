import { Component, Input, ChangeDetectionStrategy } from '@angular/core';
import { PlaylistService } from '../services/playlist_service';

@Component({
  selector: 'add-playlist',
  template: `
    <div class="add-playlist">
      <label>
        Add a playlist!
      </label>
      <div>
        <input #url id="add_playlist_url_input"
          type="url"
          name="playlist_url"
          placeholder="Enter a Spotify playlist URL"
          required
          (keyup.enter)="submit(url.value); url.value = undefined" />
        <button id="add_playlist_submit"
          (click)="submit(url.value); url.value = undefined">+</button>
      </div>
    </div>
  `,
  changeDetection: ChangeDetectionStrategy.OnPush,
  providers: [PlaylistService]
})
export class AddPlaylistComponent {
  constructor(private playlistService: PlaylistService) {}

  public submit(playlistUrl: string) {
    this.playlistService.create(playlistUrl);
  }
}
