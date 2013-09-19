/*
 * Copyright (c) 2013 Revolv Studios.
 */

package
{
	import engine.core.Test_Core;
	import engine.signal.TestSignal;
	import engine.time.TestTime;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.getQualifiedClassName;

	public class Testing extends Sprite
	{
		public static var tests:Array = [
			Test_Core,
			TestSignal,
			TestTime
		];


		public static function run():void {
			self.run();
		}

		public static function assertEquals(compare1:*, compare2:*, testId:String = ""):void {
			self.assertCount++;
			if (compare1 === compare2) {
				self.passed++;
				log("√ - " + getTestName(testId));
			} else {
				self.failed++;
				try {
					throw new Error("AssertEquals failed: " + compare1 + " !== " + compare2 + " in " + getTestName(testId));
				} catch (error:Error) {
					log("X - " + error);
				}
			}
		}

		public static function assertTrue(value:Boolean, testId:String = ""):void {
			self.assertCount++;
			if (value) {
				self.passed++;
				log("√ - " + getTestName(testId));
			} else {
				self.failed++;
				try {
					throw new Error("AssertTrue failed in " + getTestName(testId));
				} catch (error:Error) {
					log("X - " + error);
				}
			}
		}

		public static function assertFalse(value:Boolean, testId:String = ""):void {
			self.assertCount++;
			if (!value) {
				self.passed++;
				log("√ - " + getTestName(testId));
			} else {
				self.failed++;
				try {
					throw new Error("AssertFalse failed in " + getTestName(testId));
				} catch (error:Error) {
					log("X - " + error);
				}
			}
		}

		private static function getTestName(testId:String):String {
			testId = "#" + self.assertCount + (testId ? " " + testId : "");

			return getClassName(self.runningTest.type) + "." + self.runningTest.method + "['" + testId + "']";
		}

		public static function getClassName(value:*):String {
			return getQualifiedClassName(value).split("::").pop();
		}

		public static function log(...rest):void {
			trace(">TEST: " + rest);
		}

		private static var self:Testing;
		private var runningTest:Test;
		private var tests:Vector.<Test>;
		private var passed:uint;
		private var failed:uint;
		private var assertCount:uint;
		private var timeout:Timer;
		private var refresh:Timer;
		private var lastRefresh:Number;
		private var refreshTolerance:Number = 15;	// halts runs after X milliseconds to allow screen to refresh

		public function Testing() {
			timeout = new Timer(2000, 1);
			timeout.addEventListener(TimerEvent.TIMER, testTimeout);

			refresh = new Timer(1, 1);
			refresh.addEventListener(TimerEvent.TIMER, delay);
			lastRefresh = new Date().getTime();

			log("Searching for tests.");
			tests = new Vector.<Test>();
			buildTests(Testing.tests, Testing);

			self = this;
		}

		public function run():void {
			if (new Date().getTime() - lastRefresh > refreshTolerance) {
				refresh.start();
				return;
			}

			timeout.reset();
			if (runningTest) {
				if (runningTest.instance is DisplayObject) {
					removeChild(runningTest.instance);
				}
			} else {
				log("Tests started.");
			}

			if (tests.length) {
				timeout.start();
				runningTest = tests.shift();
				runningTest.instance = new runningTest.type();
				if (runningTest.instance is DisplayObject) {
					addChild(runningTest.instance);
				}
				assertCount = 0;
				runningTest.instance[runningTest.method]();
			} else {
				log("Tests completed.");
				log(passed + " tests passed!");
				log(failed + " tests failed.");
			}
		}

		private function delay(event:TimerEvent):void {
			lastRefresh = new Date().getTime();
			refresh.reset();
			run();
		}

		private function testTimeout(event:TimerEvent):void {
			log("Warning: " + getClassName(runningTest.type) + "." + runningTest.method + " timed out after " + timeout.delay + " milliseconds without calling Testing.run(). Running next test.");
			run();
		}

		private function buildTests(testTargets:Array, parent:Class):void {
			for (var i:int = 0; i < testTargets.length; i++) {
				var target:* = testTargets[i];
				if (target is Class) {
					if ("tests" in target && target["tests"].length) {
						buildTests(target["tests"], target);
					} else {
						var className:String = getClassName(target);
						log(className + " does not contain any tests. (Hint: create static " + className + ".tests array of classes or method names)");
					}
				} else if (target is String) {
					var test:Test = new Test();
					test.type = parent;
					test.method = target;
					tests.push(test);
				}
			}
		}
	}
}

internal class Test
{
	public var type:Class;
	public var instance:*;
	public var method:String;
}