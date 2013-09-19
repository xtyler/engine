/*
 * Copyright (c) 2013 Revolv Studios.
 */

package engine.signal
{
	import flash.events.IEventDispatcher;

	public class Signal
	{
		public var numListeners:uint = 0;
		public var dispatching:Boolean;
		public var valueType:Class;

		protected var head:Slot;
		protected var addLater:Slot;

		public function Signal(valueType:Class = null, eventTarget:IEventDispatcher = null, eventType:String = null, eventPriority:int = 0) {
			this.valueType = valueType ? valueType : Object;

			if (eventTarget && eventType) {
				eventTarget.addEventListener(eventType, dispatch, false, eventPriority, true);
			}
		}

		public function has(listener:Function):Boolean {
			if (listener) {
				var slot:Slot = head;
				while (slot) {
					if (slot.listener == listener) {
						return true;
					}
					slot = slot.next;
				}
			}
			return false;
		}

		public function add(listener:Function, once:Boolean = false, priority:int = 0):Slot {
			if (!listener) {
				return null;
			}

			var prev:Slot;
			var slot:Slot;
			var insert:Slot;
			var before:Slot;
			var after:Slot;

			if (dispatching) {
				slot = new Slot();
				slot.listener = listener;
				slot.once = once;
				slot.priority = priority;
				slot.next = addLater;
				addLater = slot;
				return slot;
			}

			// ====== Check for existing listener -and- find best (priority) location 'before' ====== //

			slot = head;
			while (slot) {
				if (slot.listener == listener) {
					insert = slot;
					prev ? prev.next = slot.next : head = slot.next;
					slot.next = null;
					slot = prev ? prev : head;
				} else if (slot.priority < priority && !before) {
					before = slot;
					after = prev;
				}
				prev = slot;
				slot = slot.next;
			}

			// ====== Initialize slot for addition ====== //

			if (!insert) {
				insert = new Slot();
				insert.listener = listener;
				numListeners++;
			}
			insert.once = once;
			insert.priority = priority;

			// ====== Add slot in appropriate location ====== //

			if (!before && prev) {
				prev.next = insert;
			} else if (!after) {
				insert.next = head;
				head = insert;
			} else {
				insert.next = after.next;
				after.next = insert;
			}

			return insert;
		}

		public function remove(listener:Function):Slot {
			if (!listener) {
				return null;
			}

			var prev:Slot;
			var slot:Slot = head;
			while (slot) {
				if (slot.listener == listener) {
					prev ? prev.next = slot.next : head = slot.next;
					slot.next = null;
					numListeners--;
					break;
				}
				prev = slot;
				slot = slot.next;
			}
			return slot;
		}

		public function dispatch(value:Object = null):void {
			if (value && !(value is valueType)) {
				throw new ArgumentError("Value " + value + " must be of type " + valueType + ".");
			}

			dispatching = true;

			var prev:Slot;
			var slot:Slot = head;
			while (slot) {
				if (slot.enabled) {

					// ====== Hold listener and resolve once ====== //

					var listener:Function = slot.listener;

					if (slot.once) {
						prev ? prev.next = slot.next : head = slot.next;
						slot.next = null;
						numListeners--;
						slot = prev ? prev : head;
					}

					// ====== Invoke listener with appropriate # of arguments ====== //

					if (listener.length == 1) {
						listener(value);
					} else {
						listener();
					}
				}
				prev = slot;
				slot = slot.next;
			}

			dispatching = false;

			while (addLater) {
				slot = addLater;
				addLater = addLater.next;
				slot.next = head;
				head = slot;
				add(slot.listener, slot.once, slot.priority);
			}
		}

		public function removeAll():void {
			head = null;
		}
	}
}
