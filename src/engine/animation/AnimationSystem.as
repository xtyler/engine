/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.animation
{
	import engine.core.Parts;
	import engine.core.System;

	public class AnimationSystem extends System
	{
		public var animationParts:Parts;
		
		public function AnimationSystem() {
		}

		override public function start():void {
			animationParts = engine.getParts(AnimationPart);
		}

		override public function update():void {
			
			var part:AnimationPart = animationParts.head;
			while (part) {
				
				for each (var clip:Clip in part.animation.clips) {
					
					if (!clip.startTime) {
						clip.startTime = engine.time.current;
						
					}
				}
				
				part = part.next;
			}
		}
	}
}
