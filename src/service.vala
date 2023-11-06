namespace Fabric.Desktop.Launcher {
	[DBus (name="fabric.desktop.launcher")]
	class ApplicationService : Object {
		private static GLib.Once<ApplicationService> _instance;
		public static unowned ApplicationService instance {
			get { return _instance.once(() => { return new ApplicationService(); }); }
		}

		public void show() {
			Application.instance.show();
		}

		public void toggle_visibility() {
			Application.instance.toggle_visibility();
		}
	}
}
