/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.data
{
	import engine.core.Component;
	import engine.core.Entity;

	import flash.utils.Dictionary;

	public class PartList
	{
		public var invalidated:Boolean;
		public var partType:Class;
		public var required:PartComponent;

		public var partLookup:Dictionary = new Dictionary();
		public var partPool:Part;
		
		public var head:Part;
		public var tail:Part;
		
		public var next:PartList;

		public function PartList(partType:Class) {
			this.partType = partType;
			
			// TODO: parse partType for classes to be stored in "required"
		}

		public function requires(component:Object):Boolean {
			var required:PartComponent = this.required;
			while (required) {
				var type:Class = required.type;
				if (component is type || component == type) {
					return true;
				}
			}
			return false;
		}
		
		public function get(entity:Entity):Part {
			return partLookup[entity];
		}

		public function add(entity:Entity):Part {
			var part:Part = partLookup[entity];
			if (part) {
				return part;
			} else if (partPool) {
				part = partPool;
				partPool = part.next;
			} else {
				part = new partType;
			}

			// assign required components
			var required:PartComponent = this.required;
			while (required) {
				var type:Class = required.type;
				
				var component:Component = entity.firstComponent;
				while (component) {
					if (component is type) {
						part[required.name] = component;
						break;
					}
				}
				
				if (!component) {
					return null;
				}
				required = required.next;
			}
			
			var before:Part;
			var beforeEntity:Entity = entity.next;
			while (beforeEntity) {
				before = partLookup[beforeEntity];
				if (before) {
					break;
				}
				beforeEntity = beforeEntity.next;
			}

			if (before) {
				if (before.prev) {
					before.prev.next = part;
					part.prev = before.prev;
				} else {
					head = part;
				}
				part.next = before;
				before.prev = part;
			} else {
				if (tail) {
					tail.next = part;
					part.prev = tail;
				} else {
					head = part;
				}
				tail = part;
			}

			partLookup[entity] = part;
			invalidated = true;

			return part;
		}

		public function remove(entity:Entity):void {
			var part:Part = partLookup[entity];
			if (!part) {
				return;
			}

			var required:PartComponent = this.required;
			while (required) {
				part[required.name] = null;
				required = required.next;
			}
			
			if (part.prev) {
				part.prev.next = part.next;
			} else {
				head = part.next;
			}
			
			if (part.next) {
				part.next.prev = part.prev;
			} else {
				tail = part.prev;
			}
			
			part.prev = null;
			part.next = partPool;
			partPool = part;

			delete partLookup[entity];
			invalidated = true;
		}
	}
}
