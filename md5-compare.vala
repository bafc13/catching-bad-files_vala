

namespace FileIntegrityChecker {

    public class FileComparator : Object {
        public string directory1;
        public string directory2;
        public List<string> dir1_files_list = new List<string>();
        public List<string> dir2_files_list = new List<string>();
        public List<int> dir_compare_result = new List<int>();
        


        public FileComparator(string dir1, string dir2) { //ctor
            this.directory1 = dir1;
            this.directory2 = dir2;
        }



        public void compare_directories() { //directory equal
            GLib.Dir opened_directory1 = GLib.Dir.open(directory1, 0);
            GLib.Dir opened_directory2 = GLib.Dir.open(directory2, 0);

            try{
                if (opened_directory1 != null && opened_directory2 != null){
                    traverse_directory(directory1, 0);
                    traverse_directory(directory2, 1);
                }

                if(dir1_files_list.length()!= 0 && dir2_files_list.length()!= 0 
            && dir1_files_list.length() == dir2_files_list.length()){
                    foreach (string file in this.dir1_files_list) {
                        int index = this.dir1_files_list.index(file);
                        if (index < this.dir2_files_list.length()) {
                            bool ok = check_file_integrity(file, this.dir2_files_list.nth_data(index));
                            dir_compare_result.append((int)ok);
                        }
                    }
                } else { print("ERROR while comparing directories"); }

                
                
            } catch (Error e) {
                print("Error: %s\n", e.message);
            }
            //  opened_directory1.close();
            //  opened_directory2.close();
            generate_report();
            }



        public void traverse_directory(string path, int num) {
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
                    } else { this.dir2_files_list.append(full_path); }
        
                    if (GLib.FileUtils.test(full_path, GLib.FileTest.IS_DIR)) {
                        
                        traverse_directory(full_path , num);
                    }
                }
                //  dir.close();
            } catch (Error e) {
                print("Error while traversing directory %s: %s\n",path, e.message);
            }
        }




        public bool check_file_integrity(string file1, string file2) { //control summ checker
            var sum1 = FileUtils.calculate_checksum(file1);
            var sum2 = FileUtils.calculate_checksum(file2);

            return sum1 == sum2;
        }



        public void generate_report() { //log creation
            
            FileStream log_stream = FileStream.open("log.txt", "rw");
            if(log_stream != null){
                foreach (var item in dir_compare_result){
                    log_stream.printf("%d\n", item);
                }
            } else { print("Error while generating log, cant make log.txt");}
            
        }
    }


    public class FileUtils : Object {


        public static string calculate_checksum(string file_path) {
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



        public static bool compare_files(string file1, string file2) {
            try {
                FileStream stream1 = FileStream.open(file1, "rb");
                FileStream stream2 = FileStream.open(file2, "rb");
        
                uint8[] buffer1 = new uint8[4096];
                uint8[] buffer2 = new uint8[4096];
                size_t bytes_read1, bytes_read2;
        
                bool are_equal = true;
        
                while (true) {
                    bytes_read1 = stream1.read(buffer1);
                    bytes_read2 = stream2.read(buffer2);
        

                    if (bytes_read1 != bytes_read2) {
                        are_equal = false;
                        break;
                    }
        
                    // compare readed data
                    if (bytes_read1 == 0) { // end of both files
                        break;
                    }
        
                    // buf diff
                    for (size_t i = 0; i < bytes_read1; i++) {
                        if (buffer1[i] != buffer2[i]) {
                            are_equal = false;
                            break;
                        }
                    }
        
                    if (!are_equal) {
                        break;
                    }
                }
                if (are_equal) {
                    return true;
                } else {
                    return false;
                }
        
            } catch (Error e) {
                print("Error: %s\n", e.message);
            }
        }
    }
}
