/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.core
{
	public class Engine
	{
		public var firstSystem:System;
		public var lastSystem:System;
		
		public var firstEntity:Entity;
		public var lastEntity:Entity;
		
		public function Engine()
		{
		}

		// TODO: consider moving these into entity
		public function entityAdded(entity:Entity):void {
		}
		public function entityRemoved(entity:Entity):void {
		}
		public function entityChanged(entity:Entity, component:Component):void {
		}
		
		
		


		public function hasSystem(system:System):Boolean {
			return system && system.engine == this;
		}

		public function getSystem(type:Class):* {
			var system:System = firstSystem;
			while (system) {
				if (system is type) {
					return system;
				}
				system = system.next;
			}
			return null;
		}

		public function addSystem(system:System, before:System = null):* {
			if (!system || (system.engine == this && system.next == before)) {
				return system;
			} else if (system.engine) {
				system.engine.removeSystem(system);
			}

			if (before && before.engine == this) {
				if (before.prev) {
					before.prev.next = system;
					system.prev = before.prev;
				} else {
					firstSystem = system;
				}
				system.next = before;
				before.prev = system;
			} else {
				if (lastSystem) {
					lastSystem.next = system;
					system.prev = lastSystem;
				} else {
					firstSystem = system;
				}
				lastSystem = system;
			}
			system.engine = this;
			return system;
		}

		public function removeSystem(system:System):* {
			if (!system || system.engine != this) {
				return system;
			}

			if (system.prev) {
				system.prev.next = system.next;
			} else {
				firstSystem = system.next;
			}

			if (system.next) {
				system.next.prev = system.prev;
			} else {
				lastSystem = system.prev;
			}

			system.prev = null;
			system.next = null;
			system.engine = null;
			return system;
		}


		public function hasEntity(entity:Entity):Boolean {
			return entity && entity.engine == this;
		}

		public function getEntity(name:String):* {
			var entity:Entity = firstEntity;
			while (entity) {
				if (entity.name == name) {
					return entity;
				}
				entity = entity.next;
			}
			return null;
		}

		public function addEntity(entity:Entity, before:Entity = null):* {
			if (!entity || (entity.engine == this && entity.next == before)) {
				return entity;
			} else if (entity.engine) {
				entity.engine.removeEntity(entity);
			}
			
			if (entity.transform.parent) {
				entity.transform.parent.remove(entity.transform);
			}

			if (before && before.engine == this) {
				if (before.prev) {
					before.prev.next = entity;
					entity.prev = before.prev;
				} else {
					firstEntity = entity;
				}
				entity.next = before;
				before.prev = entity;
			} else {
				if (lastEntity) {
					lastEntity.next = entity;
					entity.prev = lastEntity;
				} else {
					firstEntity = entity;
				}
				lastEntity = entity;
			}
			entity.engine = this;
			return entity;
		}

		public function removeEntity(entity:Entity):* {
			if (!entity || entity.engine != this) {
				return entity;
			}

			if (entity.prev) {
				entity.prev.next = entity.next;
			} else {
				firstEntity = entity.next;
			}

			if (entity.next) {
				entity.next.prev = entity.prev;
			} else {
				lastEntity = entity.prev;
			}

			entity.prev = null;
			entity.next = null;
			entity.engine = null;
			return entity;
		}
	}
}
