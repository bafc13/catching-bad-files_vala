/* md5-compare.vapi generated by valac 0.56.17, do not modify. */

namespace FileIntegrityChecker {
	[CCode (cheader_filename = "md5-compare.h")]
	public class FileComparator : GLib.Object {
		public GLib.List<string> dir1_files_list;
		public GLib.List<string> dir2_files_list;
		public GLib.List<int> dir_compare_result;
		public string directory1;
		public string directory2;
		public FileComparator (string dir1, string dir2);
		public bool check_file_integrity (string file1, string file2);
		public void compare_directories ();
		public void generate_report ();
		public void traverse_directory (string path, int num);
	}
	[CCode (cheader_filename = "md5-compare.h")]
	public class FileUtils : GLib.Object {
		public FileUtils ();
		public static string calculate_checksum (string file_path);
		public static bool compare_files (string file1, string file2);
	}
}
