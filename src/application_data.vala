namespace Fabric.Desktop.Launcher {
	/**
	 * Model for an application.
	 */
	class ApplicationData : Object {
		public signal void launched();

		public AppInfo info { get; private set; }
		public string id { get { return info.get_id(); } }
		public string name { get { return info.get_display_name(); } }
		public string exec { get { return info.get_executable(); } }
		public bool favorite { get; set; default = false; }
		public bool is_shown { get { return info.should_show(); } }

		private ApplicationData() { }

		public ApplicationData.from_appinfo(AppInfo info) {
			this.info = info;
		}

		/**
		 * Toggles the favorite state for the application.
		 *
		 * Use the `notify["favorite"]` signal to do whatever is needed.
		 */
		public void toggle_favorite() {
			this.favorite = !this.favorite;
		}

		/**
		 * Used to sort, favorite first, then by name.
		 */
		public static int cmp(ApplicationData a, ApplicationData b) {
			if (a.favorite && !b.favorite) {
				return -1;
			}
			else if (!a.favorite && b.favorite) {
				return 1;
			}
			return strcmp(a.name.down(), b.name.down());
		}

		/**
		 * Launches the given application, followed by the `launched` signal.
		 */
		public void launch() {
#if DONT_SPAWN_PROCESSES
			var parsed_exec = /%./.replace(exec, exec.length, 0, "").strip();
			debug("Would be launching %s (%s)", name, parsed_exec);
			debug("  desktop file ID: %s", id);
			launched();
			return;
#endif
			info.launch(null, null);
			launched();
		}
	}
}
