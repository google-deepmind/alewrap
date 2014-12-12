/* Copyright 2014 Google Inc.

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.
*/

// explicit declare
typedef unsigned char uint8_t;

// Converts the palette values to RGB.
// The shape of the rgb array should be 3 x obs.shape.
void ale_fillRgbFromPalette(uint8_t *rgb, const uint8_t *obs,
                                   size_t rgb_size, size_t obs_size);

// Initializes the ALE.
ALEInterface *ale_new(const char *rom_file);

// Deletes the ALE pointer.
void ale_gc(ALEInterface *ale);

// Applies the action and returns the obtained reward.
double ale_act(ALEInterface *ale, int action);

// Returns the screen width.
int ale_getScreenWidth(const ALEInterface *ale);

// Returns the screen height.
int ale_getScreenHeight(const ALEInterface *ale);

// Indicates whether the game ended.
// Call resetGame to restart the game.
//
// Returning of bool instead of int is important.
// The bool is converted to lua bool by FFI.
bool ale_isGameOver(const ALEInterface *ale);

// Resets the game.
void ale_resetGame(ALEInterface *ale);

// ALE save state
void ale_saveState(ALEInterface *ale);

// ALE load state
bool ale_loadState(ALEInterface *ale);

// Fills the obs with raw palette values.
//
// Currently, the palette values are even numbers from 0 to 255.
// So there are only 128 distinct values.
void ale_fillObs(const ALEInterface *ale, uint8_t *obs, size_t obs_size);

// Fills the given array with the content of the RAM.
// The obs_size should be 128.
void ale_fillRamObs(const ALEInterface *ale, uint8_t *obs, size_t obs_size);

// Returns the number of legal actions
int ale_numLegalActions(ALEInterface *ale);

// Returns the valid actions for a game
void ale_legalActions(ALEInterface *ale, int *actions, size_t size);

// Returns the number of remaining lives for a game
int ale_livesRemained(const ALEInterface *ale);

// Used by api to create a string of correct size.
int ale_getSnapshotLength(const ALEInterface *ale);

// Save the current state into a snapshot
void ale_saveSnapshot(const ALEInterface *ale, uint8_t *data, size_t length);

// Load a particular snapshot into the emulator
void ale_restoreSnapshot(ALEInterface *ale, const uint8_t *snapshot,
                         size_t size);
