package com.controller.sound
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.media.SoundTransform;
	import flash.utils.getQualifiedClassName;

	import org.greensock.TweenLite;
	import org.osflash.signals.Signal;

	public class SoundItem extends EventDispatcher
	{
		public static const FADE_COMPLETE_SIGNAL:Signal = new Signal(SoundItem);
		public static const PLAY_COMPLETE_SIGNAL:Signal = new Signal(SoundItem);

		//- PRIVATE & PROTECTED VARIABLES -------------------------------------------------------------------------

		private var _fadeTween:TweenLite;
		private var _volume:Number;

		//- PUBLIC & INTERNAL VARIABLES ---------------------------------------------------------------------------

		public var channel:SoundChannel;
		public var isLoaded:Boolean;
		public var loading:Boolean;
		public var loops:int;
		public var muted:Boolean;
		public var name:String;
		public var paused:Boolean;
		public var pausedByAll:Boolean;
		public var position:int;
		public var savedVolume:Number;
		public var sound:Sound;
		public var startTime:Number;
		public var type:int;

		//- CONSTRUCTOR	-------------------------------------------------------------------------------------------

		public function SoundItem():void
		{
			super();
		}

		/**
		 *
		 */
		public function init():void
		{
			channel = new SoundChannel();
			isLoaded = loading = false;
		}

		//- PRIVATE & PROTECTED METHODS ---------------------------------------------------------------------------

		/**
		 *
		 */
		private function fadeComplete( $stopOnComplete:Boolean ):void
		{
			if ($stopOnComplete)
				stop();

			FADE_COMPLETE_SIGNAL.dispatch(this);
		}

		//- PUBLIC & INTERNAL METHODS -----------------------------------------------------------------------------

		/**
		 * Plays the sound item.
		 *
		 * @param $startTime The time, in seconds, to start the sound at (default: 0)
		 * @param $loops The number of times to loop the sound (default: 0)
		 * @param $volume The volume to play the sound at (default: 1)
		 * @param $resumeTween If the sound volume is faded and while fading happens the sound is stopped, this will resume that fade tween (default: true)
		 *
		 * @return void
		 */
		public function play( $startTime:Number = 0, $loops:int = 0, $volume:Number = 1, $resumeTween:Boolean = true ):void
		{
			if (!paused)
				return;

			if (muted)
			{
				volume = 0;
			} else
			{
				volume = $volume;
			}
			savedVolume = $volume;
			startTime = $startTime;
			loops = $loops;
			paused = ($startTime == 0) ? true : false;

			if (!paused)
				position = startTime;
			if (sound)
			{
				channel = sound.play(position, loops, new SoundTransform(volume));
				if (channel)
				{
					channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
					channel.addEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
					paused = false;

					if ($resumeTween && (fadeTween != null))
						fadeTween.resume();
				}
			}
		}

		/**
		 * Pauses the sound item.
		 *
		 * @param $pauseTween If a fade tween is happening at the moment the sound is paused, the tween will be paused as well (default: true)
		 *
		 * @return void
		 */
		public function pause( $pauseTween:Boolean = true ):void
		{
			paused = true;
			position = channel.position;
			channel.stop();
			channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);

			if ($pauseTween && (fadeTween != null))
				fadeTween.pause();
		}

		/**
		 * Stops the sound item.
		 *
		 * @return void
		 */
		public function stop():void
		{
			if (channel)
			{
				paused = true;
				channel.stop();
				channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
				position = channel.position;
				fadeTween = null;
			}
		}

		/**
		 * Fades the sound item.
		 *
		 * @param $volume The volume to fade to (default: 0)
		 * @param $fadeLength The time, in seconds, to fade the sound (default: 1)
		 * @param $stopOnComplete Stops the sound once the fade is completed (default: false)
		 *
		 * @return void
		 */
		public function fade( $volume:Number = 0, $fadeLength:Number = 1, $stopOnComplete:Boolean = false ):void
		{
			fadeTween = TweenLite.to(channel, $fadeLength, {volume:$volume, onComplete:fadeComplete, onCompleteParams:[$stopOnComplete]});
		}

		/**
		 * Sets the volume of the sound item.
		 *
		 * @param $volume The volume, from 0 to 1, to set
		 *
		 * @return void
		 */
		public function setVolume( $volume:Number ):void
		{
			if (channel)
			{
				var curTransform:SoundTransform = channel.soundTransform;
				if (curTransform)
				{
					curTransform.volume = $volume;
					channel.soundTransform = curTransform;
				}
				_volume = $volume;
			}
		}

		/**
		 * Clears the sound item for garbage collection.
		 *
		 * @return void
		 */
		public function destroy():void
		{
			if (channel)
				channel.removeEventListener(Event.SOUND_COMPLETE, handleSoundComplete);
			sound = null;
			channel = null;
			fadeTween = null;
		}

		//- EVENT HANDLERS ----------------------------------------------------------------------------------------

		/**
		 *
		 */
		private function handleSoundComplete( $evt:Event ):void
		{
			stop();
			PLAY_COMPLETE_SIGNAL.dispatch(this);
		}

		//- GETTERS & SETTERS -------------------------------------------------------------------------------------

		/**
		 *
		 */
		public function get volume():Number
		{
			if (channel && channel.soundTransform)
				return channel.soundTransform.volume;

			return 0;
		}

		/**
		 *
		 */
		public function set volume( $val:Number ):void
		{
			setVolume($val);
		}

		/**
		 *
		 */
		public function get fadeTween():TweenLite
		{
			return _fadeTween;
		}

		/**
		 *
		 */
		public function set fadeTween( $val:TweenLite ):void
		{
			if ($val == null)
				TweenLite.killTweensOf(this);

			_fadeTween = $val;
		}

		//- HELPERS -----------------------------------------------------------------------------------------------

		override public function toString():String
		{
			return getQualifiedClassName(this);
		}

		//- END CLASS ---------------------------------------------------------------------------------------------
	}
}
