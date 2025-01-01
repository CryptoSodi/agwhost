/*******************************************************************************
 * Smash Engine
 * Copyright (C) 2009 Smash Labs, LLC
 * For more information see http://www.Smashengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package org.ash.tick
{
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getTimer;

	import org.as3commons.logging.api.ILogger;
	import org.as3commons.logging.api.getLogger;
	import org.osflash.signals.PrioritySignal;

	public class FrameTickProvider implements ITickProvider
	{
		[Inject]
		public var stage:Stage;

		/**
		 * If true, disables warnings about losing ticks.
		 */
		public var disableSlowWarning:Boolean     = true;

		/**
		 * The number of ticks that will happen every second.
		 */
		public const TICKS_PER_SECOND:int         = 30;

		/**
		 * The rate at which ticks are fired, in seconds.
		 */
		public const TICK_RATE:Number             = 1.0 / Number(TICKS_PER_SECOND);

		/**
		 * The rate at which ticks are fired, in milliseconds.
		 */
		public const TICK_RATE_MS:Number          = TICK_RATE * 1000;

		/**
		 * The maximum number of ticks that can be processed in a frame.
		 *
		 * <p>In some cases, a single frame can take an extremely long amount of
		 * time. If several ticks then need to be processed, a game can
		 * quickly get in a state where it has so many ticks to process
		 * it can never catch up. This is known as a death spiral.</p>
		 *
		 * <p>To prevent this we have a safety limit. Time is dropped so the
		 * system can catch up in extraordinary cases. If your game is just
		 * slow, then you will see that the ProcessManager can never catch up
		 * and you will constantly get the "too many ticks per frame" warning,
		 * if you have disableSlowWarning set to true.</p>
		 */
		public const MAX_TICKS_PER_FRAME:int      = 5;

		protected const _logger:ILogger           = getLogger("TickProvider");

		public var timer:Timer;
		public static var instance:FrameTickProvider;

		protected var started:Boolean             = false;
		protected var _virtualTime:int            = 0.0;
		protected var _interpolationFactor:Number = 0.0;
		protected var _timeScale:Number           = 1.0;
		protected var lastTime:int                = -1.0;
		protected var elapsed:Number              = 0.0;
		protected var _platformTime:int           = 0;
		protected var _frameCounter:uint          = 0;
		protected var _frameSignal:PrioritySignal = new PrioritySignal(Number);

		public function FrameTickProvider()
		{
			instance = this;
		}

		public function init():void
		{
			if (!started)
				start();
		}

		/**
		 * Starts the process manager. This is automatically called when the first object
		 * is added to the process manager. If the manager is stopped manually, then this
		 * will have to be called to restart it.
		 */
		public function start():void
		{
			if (started)
			{
				_logger.warn("The ProcessManager is already started.");
				return;
			}

			lastTime = -1.0;
			elapsed = 0.0;

			if (!timer)
				timer = new Timer(32);
			timer.delay = int(1000 / stage.frameRate);
			timer.start();
			timer.addEventListener(TimerEvent.TIMER, onFrame);
			started = true;
		}

		/**
		 * Stops the process manager. This is automatically called when the last object
		 * is removed from the process manager, but can also be called manually to, for
		 * example, pause the game.
		 */
		public function stop():void
		{
			if (!started)
			{
				_logger.warn("The TimeManager isn't started.");
				return;
			}

			started = false;
			timer.stop();
		}

		/**
		 * Registers an object to receive frame callbacks.
		 *
		 * @param object The object to add.
		 * @param priority The priority of the object. Objects added with higher priorities
		 * will receive their callback before objects with lower priorities. The highest
		 * (first-processed) priority is Number.MAX_VALUE. The lowest (last-processed)
		 * priority is -Number.MAX_VALUE.
		 */
		public function addFrameListener( callback:Function, priority:int = 0 ):void
		{
			if (!started)
				start();
			_frameSignal.addWithPriority(callback, priority);
		}

		/**
		 * Unregisters an object from receiving frame callbacks.
		 *
		 * @param object The object to remove.
		 */
		public function removeFrameListener( callback:Function ):void
		{
			_frameSignal.remove(callback);
		}

		public function get msPerTick():Number
		{
			return TICK_RATE_MS;
		}

		/**
		 * Forces the process manager to seek its virtualTime by the specified amount.
		 * This moves virtualTime without calling advance and without processing ticks or frames.
		 * WARNING: USE WITH CAUTION AND ONLY IF YOU REALLY KNOW THE CONSEQUENCES!
		 */
		public function seek( amount:Number ):void
		{
			_virtualTime += amount;
		}

		/**
		 * Main callback; this is called every frame and allows game logic to run.
		 */
		private function onFrame( event:TimerEvent ):void
		{
			// Track current time.
			var currentTime:Number = getTimer();
			if (lastTime < 0)
			{
				lastTime = currentTime;
				return;
			}

			timer.stop();

			// Bump the frame counter.
			_frameCounter++;

			// Calculate time since last frame and advance that much.
			var deltaTime:Number   = Number(currentTime - lastTime) * _timeScale;
			advance(deltaTime);

			// Note new last time.
			lastTime = currentTime;

			//timer.delay = 33 - ((deltaTime - 33) + (getTimer() - currentTime));
			//trace(deltaTime, timer.delay);
			timer.start();
			event.updateAfterEvent();
			if (stage)
				stage.invalidate();
		}

		public function advance( deltaTime:Number, suppressSafety:Boolean = false ):void
		{
			// Update platform time, to avoid lots of costly calls to getTimer.
			_platformTime = getTimer();

			// Note virtual time we started advancing from.
			var startTime:Number = _virtualTime;

			// Add time to the accumulator.
			elapsed += deltaTime;

			// Perform ticks, respecting tick caps.
			var tickCount:int    = 0;
			while (elapsed >= TICK_RATE_MS && (suppressSafety || tickCount < MAX_TICKS_PER_FRAME))
			{
				// Ticks always happen on interpolation boundary.
				_interpolationFactor = 0.0;

				// Update virtual time by subtracting from accumulator.
				_virtualTime += TICK_RATE_MS;
				elapsed -= TICK_RATE_MS;

				tickCount++;
			}

			// Safety net - don't do more than a few ticks per frame to avoid death spirals.
			if (tickCount >= MAX_TICKS_PER_FRAME && !suppressSafety && !disableSlowWarning)
			{
				// By default, only show when profiling.
				_logger.warn("Exceeded maximum number of ticks for frame (" + elapsed.toFixed() + "ms dropped) .");
			}

			// Make sure that we don't fall behind too far. This helps correct
			// for short-term drops in framerate as well as the scenario where
			// we are consistently running behind.
			if (elapsed > 300)
				elapsed = 300;
			if (elapsed < 0)
				elapsed = 0;

			// Update objects wanting OnFrame callbacks.
			_interpolationFactor = elapsed / TICK_RATE_MS;
			_frameSignal.dispatch(deltaTime / 1000);
		}

		/**
		 * The scale at which time advances. If this is set to 2, the game
		 * will play twice as fast. A value of 0.5 will run the
		 * game at half speed. A value of 1 is normal.
		 */
		public function get timeScale():Number
		{
			return _timeScale;
		}

		/**
		 * @private
		 */
		public function set timeScale( value:Number ):void
		{
			_timeScale = value;
		}

		/**
		 * TweenMax uses timeScale as a config property, so by also having a
		 * capitalized version, we can tween TimeScale instead and get along
		 * just fine.
		 */
		public function set TimeScale( value:Number ):void
		{
			timeScale = value;
		}

		/**
		 * @private
		 */
		public function get TimeScale():Number
		{
			return timeScale;
		}

		/**
		 * Used to determine how far we are between ticks. 0.0 at the start of a tick, and
		 * 1.0 at the end. Useful for smoothly interpolating visual elements.
		 */
		public function get interpolationFactor():Number
		{
			return _interpolationFactor;
		}

		/**
		 * The amount of time that has been processed by the process manager. This does
		 * take the time scale into account. Time is in milliseconds.
		 */
		public function get virtualTime():Number
		{
			return _virtualTime;
		}

		/**
		 * Current time reported by getTimer(), updated every frame. Use this to avoid
		 * costly calls to getTimer(), or if you want a unique number representing the
		 * current frame.
		 */
		public function get platformTime():Number
		{
			return _platformTime;
		}

		/**
		 * Integer identifying this frame. Incremented by one for every frame.
		 */
		public function get frameCounter():uint
		{
			return _frameCounter;
		}

		public function destroy():void
		{
			if (started)
				stop();
		}
	}
}
