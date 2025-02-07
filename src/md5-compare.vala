
namespace FileIntegrityChecker {

    public class FileComparator : Object {
        public string directory1;
        public string directory2;
        public List<string> dir1_files_list = new List<string>();
        public List<string> dir2_files_list = new List<string>();
        public List<int> dir_compare_int_result = new List<int>();
        
        public FileComparator(string dir1, string dir2) {
            this.directory1 = dir1;
            this.directory2 = dir2;
        }



        public void compare_directories() {
            
            try{
                GLib.Dir opened_directory1 = GLib.Dir.open(directory1, 0);
                GLib.Dir opened_directory2 = GLib.Dir.open(directory2, 0);
                if (opened_directory1 != null && opened_directory2 != null){
                    traverse_directory(directory1, 0); //getting the file paths
                    traverse_directory(directory2, 1);
                }
                int index = 0;
                foreach (string file in this.dir1_files_list) {
                    if (index < this.dir2_files_list.length()) {
                        bool ok = check_file_integrity(file, this.dir2_files_list.nth_data(index));
                        dir_compare_int_result.append((int)ok);
                    }
                    index++;
                }
                
            } catch (Error e) {
                print("Error: %s\n", e.message);
            }
            generate_report();
            }



        public void traverse_directory(string path, int num) { //getting the file paths
            try {
                var dir = GLib.Dir.open(path);
                string? entry;
                while ((entry = dir.read_name()) != null) {
                    if (entry == "." || entry == "..") {
                        continue; 
                    }
                    string full_path = path + "/" + entry;
                    if(num == 0){
                        this.dir1_files_list.append(full_path);
                    } 
                    if(num == 1) { 
                        this.dir2_files_list.append(full_path);
                    }
        
                    if (GLib.FileUtils.test(full_path, GLib.FileTest.IS_DIR)) {
                        traverse_directory(full_path , num); //if dir inside - getting this dir paths
                    }
                }
            } catch (Error e) {
                print("Error while traversing directory %s: %s\n",path, e.message);
            }
        }



        public bool check_file_integrity(string file1, string file2) { //control summ checker
            var sum1 = FileUtils.calculate_checksum(file1);
            var sum2 = FileUtils.calculate_checksum(file2);
            return sum1 == sum2;
        }



        public void generate_report() { // log creation
            try {
                File file = File.new_for_path("log");
                size_t bwritten = 0;
                FileOutputStream log_stream = file.replace(null, false, GLib.FileCreateFlags.NONE, null); 
                if (log_stream != null) {
                    int join_0_count = 0;

                    foreach (var item in dir_compare_int_result){
                        if(item == 0){
                            join_0_count++;
                        }
                    }
                    int index = 0;
                    
                    log_stream.printf(out bwritten,null,"Legend: 1 - success copy, 0 - failed copy(error)\n");
                    log_stream.printf(out bwritten,null,"Founded errors - %d\n",join_0_count);
                    log_stream.printf(out bwritten, null, "Files count - %d\n",dir_compare_int_result.length());
                    foreach (var item in dir_compare_int_result) {
                        log_stream.printf(out bwritten,null,"%d  -  %s\n", item, dir1_files_list.nth_data(index));
                        index++;
                    }
                    log_stream.close(null); 
                } else {
                    print("Error while generating log, can't open log\n");
                }
            } catch (Error e) {
                print("Error while generating log: %s\n", e.message);
            }
        }
    }


    public class FileUtils : Object {
        public List<int> error_lines = new List<int>();

        public static string calculate_checksum(string file_path) { //md5 hash sum calculate
            var checksum = new Checksum(GLib.ChecksumType.MD5);
            string md5_sum;
            try{
                FileStream stream = FileStream.open(file_path, "rb");
                if(stream != null){
                    uint8[] buffer = new uint8[4096];
                    size_t bytes_read;
                    while ((bytes_read = stream.read(buffer)) > 0) {
                        checksum.update(buffer, (size_t) bytes_read);
                    }
                }                
            } catch (Error e) {
                print("Error while calculating checksum: %s\n", e.message);
                return "Error";
            }
            md5_sum = checksum.get_string();
            return md5_sum;
        }


    public string[] compare_files_lines(string file1_path, string file2_path) {
        StringBuilder result_file_1 = new StringBuilder();
        StringBuilder result_file_2 = new StringBuilder();
        try {
            var file1 = File.new_for_path(file1_path);
            var file2 = File.new_for_path(file2_path);
    
            var file1_stream = new DataInputStream(file1.read());
            var file2_stream = new DataInputStream(file2.read());
    
            string? line1 = null;
            string? line2 = null;
            int line_number = 1;
    
            bool error_append = true;
            line1 = file1_stream.read_line();
            line2 = file2_stream.read_line();
            while(true){

                if (line1 == null) line1 = "";
                if (line2 == null) line2 = "";
                line1 = line1.make_valid(line1.length);
                size_t bread = 0;
                size_t bwritten = 0; 
                var buf = line2.locale_to_utf8(line2.length, out bread, out bwritten, null);
                if(buf == null){
                    buf = line2.make_valid(line2.length);
                }
                    if (error_append){
                        result_file_2.append("\n" + buf + "\n");
                        error_append = false;
                    } else { result_file_2.append(buf + "\n"); }
                    
                if (line1 != line2) {
                    result_file_2.append("String before is different");
                    error_append = true;
                    error_lines.append(line_number);
                }

                line_number++;
                line1 = file1_stream.read_line();
                line2 = file2_stream.read_line();
                if(line1 == null && line2 == null){    
                    break;
                }
            }
            string line3;
            file1_stream.close();
            file1_stream = new DataInputStream(file1.read());
            while ((line3 = file1_stream.read_line()) != null) {
                line3 = line3.make_valid(line3.length);
                result_file_1.append(line3 + "\n");
            }
            } catch (Error e) {
                result_file_1.append(@"File read error zzz: $(e.message)\n");
                result_file_2.append(@"File read error zzz: $(e.message)\n");
            }
        return {result_file_1.str,result_file_2.str};
    }
}
}
