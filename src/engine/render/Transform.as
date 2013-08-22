/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.render
{
	import engine.core.Component;
	import engine.core.Entity;

	import flash.geom.Vector3D;

	public class Transform extends Component
	{
		static var defaultPosition:Vector3D = new Vector3D(0, 0, 0);
		static var defaultRotation:Vector3D = new Vector3D(0, 0, 0);
		static var defaultScale:Vector3D = new Vector3D(1, 1, 1);
		
		
		public function get position():Vector3D {
			return _position != defaultPosition ? _position : (_position = defaultPosition.clone());
		}
		internal var _position:Vector3D = defaultPosition;

		public function get rotation():Vector3D {
			return _rotation != defaultRotation ? _rotation : (_rotation = defaultRotation.clone());
		}
		internal var _rotation:Vector3D = defaultRotation;

		public function get scale():Vector3D {
			return _scale != defaultScale ? _scale : (_scale = defaultScale.clone());
		}
		internal var _scale:Vector3D = defaultScale;
		
//		public var x:Number = 0;
//		public var y:Number = 0;
//		public var z:Number = 0;
//		public var rotationX:Number = 0;
//		public var rotationY:Number = 0;
//		public var rotationZ:Number = 0;
//		public var scaleX:Number = 1;
//		public var scaleY:Number = 1;
//		public var scaleZ:Number = 1;
		
		public var parent:Transform;
		public var numChildren:uint;
		public var firstChild:Transform;
		public var lastChild:Transform;
		public var previousSibling:Transform;
		public var nextSibling:Transform;
		
		public var owner:Transform;
		public var skin:Transform;
		public var content:Transform;
		
		public function Transform() {
		}

		public function setSkin(skin:Transform):void {
			// TODO: remove old skin
//			if (this.skin && this.skin.content) {
//				if (firstChild) {
//					firstChild.entity.prev = this.skin.content.entity;
//					this.skin.content.entity.next = firstChild.entity;
//
//					lastChild.entity.last.next = this.skin.content.entity.last.next;
//					this.skin.content.entity.last.next.prev = lastChild.entity.last;
//					this.skin.content.entity.last = lastChild.entity.last;
//
//					var child:Transform = firstChild;
//					while (child) {
//						child.owner = this.skin.content;
//						child = child.nextSibling;
//					}
//				}
//			}
			
			this.skin = skin;
			
			// TODO: add new skin
			if (skin) {
//				entity.next = skin.entity;
//				skin.entity.prev = entity;
//
//				skin.entity.last.next = entity.last.next;
//				entity.last = skin.entity.last;
				
				if (skin.content && firstChild) {
					firstChild.entity.prev = skin.content.entity;
					skin.content.entity.next = firstChild.entity;
					
					lastChild.entity.last.next = skin.content.entity.last.next;
					skin.content.entity.last.next.prev = lastChild.entity.last;
					skin.content.entity.last = lastChild.entity.last;
					
					var child:Transform = firstChild;
					while (child) {
						child.owner = skin.content;
						child = child.nextSibling;
					}
				}
			}
		}
		
		public function has(child:Transform):Boolean {
			return child && child.parent == this;
		}
		
		public function add(child:Transform, before:Transform = null):Transform {
			if (!child || (child.parent == this && child.nextSibling == before)) {
				return child;
			} else if (child.parent) {
				child.parent.remove(child);
			}
			
			var prevEntity:Entity;
			var nextEntity:Entity;
			var content:Entity = skin && skin.content ? skin.content.entity : null;

			if (before && before.parent == this) {
				if (before.previousSibling) {
					before.previousSibling.nextSibling = child;
					child.previousSibling = before.previousSibling;
					prevEntity = child.previousSibling.entity.last;
				} else {
					firstChild = child;
					prevEntity = content ? content : entity;
				}
				child.nextSibling = before;
				before.previousSibling = child;
			} else {
				if (lastChild) {
					lastChild.nextSibling = child;
					child.previousSibling = lastChild;
					prevEntity = lastChild.entity.last;
				} else {
					firstChild = child;
					prevEntity = content ? content : entity;
				}
				lastChild = child;
				
				var ancestor:Transform = owner;
				while (ancestor && ancestor.entity.last == entity.last) {
					ancestor.entity.last = child.entity.last;
					ancestor = ancestor.owner;
				}
				entity.last = child.entity.last;
			}
			child.parent = this;
			numChildren++;
			
			if (prevEntity) {
				nextEntity = content ? content.last.next : prevEntity.next;
				prevEntity.next = child.entity;
				child.entity.prev = prevEntity;
			}
			if (nextEntity) {
				nextEntity.prev = child.entity.last;
				child.entity.last.next = nextEntity;
			}
			child.owner = this;
			
			if (entity.engine) {
				entity.engine.entityAdded(child.entity);
			}
			
			return child;
		}
		
		public function remove(child:Transform):Transform {
			if (!child || child.parent != this) {
				return child;
			}
			
			if (entity.engine) {
				entity.engine.entityRemoved(child.entity);
			}
			
			if (child.previousSibling) {
				child.previousSibling.nextSibling = child.nextSibling;
			} else {
				firstChild = child.nextSibling;
			}

			if (child.nextSibling) {
				child.nextSibling.previousSibling = child.previousSibling;
			} else {
				lastChild = child.previousSibling;
			}
			child.previousSibling = null;
			child.nextSibling = null;
			child.parent = null;
			numChildren--;
			
//			var ancestor:Transform = this;
//			while (ancestor && ancestor.entity.last == child.entity.last) {
//				ancestor.entity.last = child.entity.prev;
//				ancestor = ancestor.owner;
//			}
//			
//			if (child.entity.prev) {
//				child.entity.prev.next = child.entity.last.next;
//				child.entity.prev = null;
//			}
//			if (child.entity.last.next) {
//				child.entity.last.next.prev = child.entity.prev;
//				child.entity.last.next = null;
//			}
//			child.owner = null;
			
			return child;
		}
		
		public function removeAll():void {
		}
	}
}
