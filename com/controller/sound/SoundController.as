package com.controller.sound
{
	import com.enum.AudioEnum;
	import com.model.asset.AssetModel;
	import com.service.loading.LoadPriority;

	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	import org.greensock.plugins.TweenPlugin;
	import org.greensock.plugins.VolumePlugin;
	import org.shared.ObjectPool;

	public class SoundController extends EventDispatcher
	{
		//- PRIVATE & PROTECTED VARIABLES -------------------------------------------------------------------------
		private static const HIGHLIGHT_SCALAR:Number = .2;

		// singleton instance
		public static var instance:SoundController;

		private var _areSFXMuted:Boolean             = false;
		private var _sfxVolume:Number                = 1.0;
		private var _assetModel:AssetModel;
		private var _currentVoiceOver:String;
		private var _currentMusic:String;
		private var _isMusicMuted:Boolean            = false;
		private var _musicVolume:Number              = 1.0;
		private var _sounds:Vector.<SoundItem>;
		private var _soundsRef:Dictionary;
		private var _volumeScalar:Number             = 1;

		public function SoundController()
		{
			TweenPlugin.activate([VolumePlugin]);
			instance = this;
			_sounds = new Vector.<SoundItem>;
			_soundsRef = new Dictionary(true);

			SoundItem.FADE_COMPLETE_SIGNAL.add(handleFadeComplete);
			SoundItem.PLAY_COMPLETE_SIGNAL.add(handleSoundPlayComplete);
		}

		public function addAudio( urlToLoad:String = null, preloadedSound:Sound = null ):void
		{
			var si:SoundItem;
			if (preloadedSound)
			{
				//a sound has been loaded in so lets add it to the sound item
				si = _soundsRef[urlToLoad];
				if (!si)
					si = createNewSoundItem(urlToLoad);
				si.sound = preloadedSound;
				si.loading = false;
				si.isLoaded = true;

				playSound(urlToLoad, si.savedVolume, si.startTime, si.loops);

				//clear the cache from the asset model so that the sound can be reloaded at a later time if needed
				_assetModel.removeFromCache(urlToLoad);
			} else if (urlToLoad)
			{
				//make sure a soundItem was created for this sound before loading it
				if (_soundsRef.hasOwnProperty(urlToLoad))
				{
					si = _soundsRef[urlToLoad];
					//make sure the type is not muted before we laod it
					if (((si.type == AudioEnum.TYPE_SFX || si.type == AudioEnum.TYPE_VOICEOVER) && !_areSFXMuted) ||
						(si.type == AudioEnum.TYPE_MUSIC && !_isMusicMuted))
					{
						si.loading = true;
						_assetModel.getFromCache(urlToLoad, null, LoadPriority.DONT_GIVE_A_SHIT);
					} else if (si.type == AudioEnum.TYPE_MUSIC) //save out to _currentMusic so when unmuted we can play it
						_currentMusic = si.name;
				}
			}
		}

		public function removeAudio( name:String ):void
		{
			if (_soundsRef[name])
			{
				_soundsRef[name] = null;
				delete _soundsRef[name];

				var len:int = _sounds.length;
				for (var i:int = 0; i < len; i++)
				{
					if (_sounds[i].name == name)
					{
						ObjectPool.give(_sounds[i]);
						_sounds.splice(i, 1);
						break;
					}
				}
			}
		}

		public function removeAllAudio():void
		{
			_sounds.length = 0;
			_soundsRef = new Dictionary(true);
		}

		/**
		 * Plays or resumes a sound from the sound dictionary with the specified name.  If the sounds in the dictionary were muted by
		 * the muteAllSounds() method, no sounds are played until unmuteAllSounds() is called.
		 *
		 * @param $name The string identifier of the sound to play
		 * @param $volume A number from 0 to 1 representing the volume at which to play the sound (default: 1)
		 * @param $startTime A number (in milliseconds) representing the time to start playing the sound at (default: 0)
		 * @param $loops An integer representing the number of times to loop the sound (default: 0)
		 * @param $resumeTween A boolean that indicates if a faded sound's volume should resume from the last saved state (default: true)
		 *
		 * @return void
		 */
		public function playSound( name:String, volume:Number = 1, startTime:Number = 0, loops:int = 0, resumeTween:Boolean = true ):void
		{
			if (_soundsRef[name])
			{
				var si:SoundItem = SoundItem(_soundsRef[name]);
				if (!si.sound)
				{
					//see if we need to laod this due to being muted before
					if (!si.loading && ((si.type == AudioEnum.TYPE_SFX || si.type == AudioEnum.TYPE_VOICEOVER) && !_areSFXMuted) ||
						(si.type == AudioEnum.TYPE_MUSIC && !_isMusicMuted))
					{
						addAudio(si.name);
					} else if (si.type == AudioEnum.TYPE_MUSIC)
						_currentMusic = si.name;
					return;
				}

				if (si.type == AudioEnum.TYPE_VOICEOVER)
				{
					if (_areSFXMuted)
						return;
					//stop the old voiceover and remove it from memory
					if (_currentVoiceOver)
						stopSound(_currentVoiceOver, _currentVoiceOver != name);
					_currentVoiceOver = name;

					si.play(startTime, loops, volume * _sfxVolume, resumeTween);

					//reduce the volume of all other sounds while the voiceover is playing
					highlightSound(name, HIGHLIGHT_SCALAR);
				} else if (si.type == AudioEnum.TYPE_MUSIC)
				{
					if (_isMusicMuted)
						return;
					//stop the old music and remove it from memory
					if (_currentMusic && _currentMusic != name)
						stopSound(_currentMusic);
					si.play(startTime, loops, volume * _musicVolume, resumeTween);
					_currentMusic = name;
				} else
				{
					if (_areSFXMuted)
						return;
					si.play(startTime, loops, volume * _sfxVolume, resumeTween);
				}
			} else
			{
				createNewSoundItem(name, volume, startTime, loops, resumeTween);
				addAudio(name);
			}
		}

		/**
		 * Pauses the specified sound.
		 *
		 * @param $name The string identifier of the sound
		 * @param $pauseTween A boolean that either pauses the fadeTween or allows it to continue (default: true)
		 *
		 * @return void
		 */
		public function pauseSound( name:String, pauseTween:Boolean = true ):void
		{
			if (_soundsRef[name])
			{
				var si:SoundItem = SoundItem(_soundsRef[name]);
				si.pause(pauseTween);
			}
		}

		/**
		 * Stops the specified sound.
		 *
		 * @param $name The string identifier of the sound
		 *
		 * @return void
		 */
		public function stopSound( name:String, destroy:Boolean = true ):void
		{
			if (_soundsRef.hasOwnProperty(name))
			{
				var si:SoundItem = SoundItem(_soundsRef[name]);
				si.stop();
				//remove the music from memory
				if (si.type == AudioEnum.TYPE_MUSIC)
				{
					if (destroy)
						removeAudio(name);
				}
				//remove the voiceover from memory
				if (si.type == AudioEnum.TYPE_VOICEOVER)
				{
					unhighlightSound(name, HIGHLIGHT_SCALAR); //reverse the volume change to highlight the voiceover
					if (destroy)
						removeAudio(name);
					_currentVoiceOver = null;
				}
			}
		}

		/**
		 * Plays all the sounds that are in the sound dictionary.
		 *
		 * @param $resumeTweens A boolean that resumes all unfinished fade tweens (default: true)
		 * @param $useCurrentlyPlayingOnly A boolean that only plays the sounds which were currently playing before a pauseAllSounds() or stopAllSounds() call (default: false)
		 *
		 * @return void
		 */
		public function playAllSounds( resumeTweens:Boolean = true, useCurrentlyPlayingOnly:Boolean = false ):void
		{
			var len:int = _sounds.length;
			var si:SoundItem;
			for (var i:int = 0; i < len; i++)
			{
				si = _sounds[i];
				if (useCurrentlyPlayingOnly)
				{
					if (si.pausedByAll)
					{
						si.pausedByAll = false;
						playSound(si.name, si.volume, 0, 0, resumeTweens);
					}
				} else
				{
					playSound(si.name, si.volume, 0, 0, resumeTweens);
				}
			}
		}

		/**
		 * Pauses all the sounds that are in the sound dictionary.
		 *
		 * @param $pauseTweens A boolean that either pauses each SoundItem's fadeTween or allows them to continue (default: true)
		 * @param $useCurrentlyPlayingOnly A boolean that only pauses the sounds which are currently playing (default: true)
		 *
		 * @return void
		 */
		public function pauseAllSounds( pauseTweens:Boolean = true, useCurrentlyPlayingOnly:Boolean = true ):void
		{
			var len:int = _sounds.length;
			var si:SoundItem;
			for (var i:int = 0; i < len; i++)
			{
				si = _sounds[i];
				if (useCurrentlyPlayingOnly)
				{
					if (!si.paused)
					{
						si.pausedByAll = true;
						pauseSound(si.name, pauseTweens);
					}
				} else
				{
					pauseSound(si.name, pauseTweens);
				}
			}
		}

		/**
		 * Stops all the sounds that are in the sound dictionary.
		 *
		 * @param $useCurrentlyPlayingOnly A boolean that only stops the sounds which are currently playing (default: true)
		 *
		 * @return void
		 */
		public function stopAllSounds( useCurrentlyPlayingOnly:Boolean = true ):void
		{
			var len:int = _sounds.length;
			var si:SoundItem;
			for (var i:int = 0; i < len; i++)
			{
				si = _sounds[i];
				if (useCurrentlyPlayingOnly)
				{
					if (!si.paused)
					{
						si.pausedByAll = true;
						stopSound(si.name);
					}
				} else
				{
					stopSound(si.name);
				}
			}
		}

		/**
		 * Fades the sound to the specified volume over the specified amount of time.
		 *
		 * @param $name The string identifier of the sound
		 * @param $targVolume The target volume to fade to, between 0 and 1 (default: 0)
		 * @param $fadeLength The time to fade over, in seconds (default: 1)
		 * @param $stopOnComplete Added by Danny Miller from K2xL, stops the sound once the fade is done if set to true
		 *
		 * @return void
		 */
		public function fadeSound( $name:String, $targVolume:Number = 0, $fadeLength:Number = 1, $stopOnComplete:Boolean = false ):void
		{
			var si:SoundItem = SoundItem(_soundsRef[$name]);
			si.fade($targVolume, $fadeLength, $stopOnComplete);
		}

		public function toggleSFXMute():void
		{
			_areSFXMuted = !_areSFXMuted;

			var len:int = _sounds.length;
			var si:SoundItem;

			for (var i:int = 0; i < len; i++)
			{
				si = _sounds[i];
				if (si.type != AudioEnum.TYPE_MUSIC)
				{
					si.muted = _areSFXMuted;
					if (_areSFXMuted)
						si.setVolume(0);
					else
						si.setVolume(si.savedVolume);
				}
			}
		}

		public function toggleMusicMute():void
		{
			_isMusicMuted = !_isMusicMuted;

			var len:int = _sounds.length;
			var si:SoundItem;

			for (var i:int = 0; i < len; i++)
			{
				si = _sounds[i];
				if (si.type == AudioEnum.TYPE_MUSIC)
				{
					si.muted = _isMusicMuted;
					if (_isMusicMuted)
						si.setVolume(0);
					else
						si.setVolume(si.savedVolume);
					if (_currentMusic == si.name)
					{
						if (_isMusicMuted)
							stopSound(si.name, false);
						else
							playSound(si.name, si.volume, si.startTime, si.loops);
					}
				}
			}
		}

		public function setSFXVolume( v:Number ):void
		{
			_sfxVolume = v;
			var len:int = _sounds.length;
			var si:SoundItem;

			for (var i:int = 0; i < len; i++)
			{
				si = _sounds[i];
				if (si.type != AudioEnum.TYPE_MUSIC)
				{
					si.setVolume(si.savedVolume * _sfxVolume);
				}
			}
		}

		public function setMusicVolume( v:Number ):void
		{
			_musicVolume = v;

			var len:int = _sounds.length;
			var si:SoundItem;

			for (var i:int = 0; i < len; i++)
			{
				si = _sounds[i];
				if (si.type == AudioEnum.TYPE_MUSIC)
				{
					si.setVolume(si.savedVolume * _musicVolume);

					if (_currentMusic == si.name)
						playSound(si.name, si.volume, si.startTime, si.loops);
				}
			}
		}

		/**
		 * Sets the volume of the specified sound.
		 *
		 * @param $name The string identifier of the sound
		 * @param $volume The volume, between 0 and 1, to set the sound to
		 *
		 * @return void
		 */
		public function setSoundVolume( name:String, volume:Number ):void
		{
			var s:SoundItem;
			if (_soundsRef[name])
				_soundsRef[name].setVolume(volume);
		}

		/**
		 * Gets the position of the specified sound.
		 *
		 * @param $name The string identifier of the sound
		 *
		 * @return Number The current position of the sound, in milliseconds
		 */
		public function getSoundPosition( name:String ):Number
		{
			if (_soundsRef[name])
				return _soundsRef[name].channel.position;
			return 0;
		}

		/**
		 * Gets the SoundItem instance of the specified sound.
		 *
		 * @param $name The string identifier of the SoundItem
		 *
		 * @return SoundItem The SoundItem
		 */
		public function getSoundItem( name:String ):SoundItem
		{
			return SoundItem(_soundsRef[name]);
		}

		/**
		 * Reduces the volume of all other sounds to make the specified sound easier to hear
		 * @param name The name of the sound to highlight
		 * @param scalar The volume scalar to apply to sounds
		 */
		public function highlightSound( name:String, scalar:Number ):void
		{
			for (var i:int = 0; i < _sounds.length; i++)
			{
				if (_sounds[i].name != name)
					_sounds[i].setVolume(_sounds[i].volume * scalar);
			}
			_volumeScalar = scalar;
		}

		/**
		 * Reverts the highlighting that was done by a call to highlightSound
		 * @param name The name of the sound that was highlighted
		 * @param scalar The volume scalar to apply to sounds
		 */
		public function unhighlightSound( name:String, scalar:Number ):void
		{
			for (var i:int = 0; i < _sounds.length; i++)
			{
				if (_sounds[i].name != name)
					_sounds[i].setVolume(_sounds[i].volume / scalar);
			}
			_volumeScalar = 1;
		}

		//- EVENT HANDLERS ----------------------------------------------------------------------------------------

		/**
		 * Dispatched once a sound's fadeTween is completed if the sound was called to fade.
		 */
		private function handleFadeComplete( si:SoundItem ):void
		{
			//TODO dispatch a signal or do something when the fade is complete
		}

		/**
		 * Dispatched when a SoundItem has finished playback.
		 */
		private function handleSoundPlayComplete( si:SoundItem ):void
		{
			if (si.type == AudioEnum.TYPE_VOICEOVER)
			{
				//revert the volume highlighting and remove the audio from memory
				unhighlightSound(si.name, HIGHLIGHT_SCALAR);
				removeAudio(si.name);
				_currentVoiceOver = null;
			}
		}

		private function createNewSoundItem( name:String, volume:Number = 1, startTime:Number = 0, loops:int = 0, resumeTween:Boolean = true ):SoundItem
		{
			var si:SoundItem = ObjectPool.get(SoundItem);
			si.init();
			si.name = name;
			si.position = 0;
			si.paused = true;

			//set the type of the audio and the volume
			if (name.indexOf('sfx') > -1)
			{
				si.volume = (_areSFXMuted) ? 0 : volume;
				si.muted = _areSFXMuted;
				si.type = AudioEnum.TYPE_SFX;
			} else if (name.indexOf('music') > 1)
			{
				si.volume = (_isMusicMuted) ? 0 : volume;
				si.muted = _isMusicMuted;
				si.type = AudioEnum.TYPE_MUSIC;
			} else
			{
				si.volume = (_areSFXMuted) ? 0 : volume;
				si.muted = _areSFXMuted;
				si.type = AudioEnum.TYPE_VOICEOVER;
			}

			si.savedVolume = volume;
			si.startTime = startTime;
			si.loops = loops;
			si.pausedByAll = false;

			_soundsRef[name] = si;
			_sounds.push(si);

			return si;
		}

		//- GETTERS & SETTERS -------------------------------------------------------------------------------------

		/**
		 *
		 */
		public function get areSFXMuted():Boolean  { return _areSFXMuted; }

		public function get isMusicMuted():Boolean  { return _isMusicMuted; }

		public function get sfxVolume():Number  { return _sfxVolume; }

		public function get musicVolume():Number  { return _musicVolume; }

		//- HELPERS -----------------------------------------------------------------------------------------------

		override public function toString():String
		{
			return getQualifiedClassName(this);
		}

		[Inject]
		public function set assetModel( v:AssetModel ):void  { _assetModel = v; }
	}
}
