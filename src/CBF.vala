
public class CBF : Gtk.Application {
    private Gtk.TextView text_view; //error file viewer
    private Gtk.TextView text_view1; //initial file viewer
    private Gtk.ApplicationWindow window;
    private Gtk.Label line_number_label; //file lines
    private Gtk.Box vbox_for_files; 
    private string dir1_path;
    private string dir2_path;
    public List<string> dir1_files_list;
    public List<string> dir2_files_list;
    private FileIntegrityChecker.FileComparator comparator;

    public CBF () {
        Object (application_id: "bafc13.CBF.test");
    }


    public override void activate () {
        this.window = new Gtk.ApplicationWindow (this) {
            title = "catching-bad-files",
            default_width = 1366,
            default_height = 768
        };

        var toolbar = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        toolbar.add_css_class ("toolbar");

        var open_dir1_image = new Gtk.Image.from_icon_name ("document-open");
        var open_dir1_label = new Gtk.Label ("Open initial directory");
        var open_dir2_image = new Gtk.Image.from_icon_name ("document-open");
        var open_dir2_label = new Gtk.Label ("Open bad directory");

        var open_dir1_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        open_dir1_button_box.append (open_dir1_image);
        open_dir1_button_box.append (open_dir1_label);
        
        var open_dir2_button_box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
        open_dir2_button_box.append (open_dir2_image);
        open_dir2_button_box.append (open_dir2_label);


        var open_dir1_button = new Gtk.Button ();
        open_dir1_button.add_css_class ("button");
        open_dir1_button.child = open_dir1_button_box;
        open_dir1_button.clicked.connect(on_open_dir1_button_clicked);

        var open_dir2_button = new Gtk.Button ();
        open_dir2_button.add_css_class ("button");
        open_dir2_button.child = open_dir2_button_box;
        open_dir2_button.clicked.connect(on_open_dir2_button_clicked);                
    
        var start_compare_label = new Gtk.Label ("Start compare");
        var start_compare_button_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        start_compare_button_box.append (start_compare_label);
        var start_compare_button = new Gtk.Button ();
        start_compare_button.add_css_class ("button");
        start_compare_button.child = start_compare_button_box;
        start_compare_button.clicked.connect(on_start_compare_button_clicked);
         
        toolbar.append (open_dir1_button);
        toolbar.append (open_dir2_button);
        toolbar.append (start_compare_button);

        
        var scroll_view = new Gtk.ScrolledWindow () { //compare result viewer
            hscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            vscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            vexpand = true,
            valign = Gtk.Align.FILL
        };
        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        vbox.append (toolbar);
        vbox_for_files = new Gtk.Box (Gtk.Orientation.VERTICAL, 0){

        };

        vbox.append (scroll_view);
        scroll_view.set_child (vbox_for_files);

        this.window.child = vbox;
        this.window.present ();
    }



    private void on_open_dir1_button_clicked () {
        var file_dialog = new Gtk.FileDialog () {
            title = "Open Initial Directory"
        }; 

        file_dialog.select_folder.begin(this.window, null, (obj, res) => {
            try {
                var dir = file_dialog.select_folder.end (res);
                this.dir1_path = dir.get_path ();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        });
    }


    private void on_open_dir2_button_clicked () {
        var file_dialog = new Gtk.FileDialog () {
            title = "Open Bad Directory"
        };
        file_dialog.select_folder.begin(this.window, null, (obj, res) => {
            try {
                var dir = file_dialog.select_folder.end (res);
                this.dir2_path = dir.get_path ();
            } catch (Error e) {
                stderr.printf ("Error: %s\n", e.message);
            }
        }); 
    }

    private void on_start_compare_button_clicked () {
        try{
            if(dir1_path != null && dir2_path != null){
                comparator = new FileIntegrityChecker.FileComparator(dir1_path,dir2_path);
                comparator.compare_directories(); //compare dir`s
                this.dir2_files_list = new List<string>();
                foreach (var item in comparator.dir2_files_list){
                    dir2_files_list.append (item); 
                }

                List<int> error_files_indexes = new List<int>();
            
                File file = File.new_for_path("log");
                FileIOStream log_iostream = file.open_readwrite (null);
                DataInputStream log_data_iostream = new DataInputStream (log_iostream.input_stream);
                if (log_data_iostream != null) {
                    string? line;
                    int temp_index = 0;
                    while ((line = log_data_iostream.read_line(null,null)) != null) {
                        if(line[0] == '0'){
                            error_files_indexes.append (temp_index - 3);
                        }
                        temp_index++;
                    }
                } else {
                    print("Cannot open log file\n");
                }
                int temp_index = 0;
                foreach(var temp_file in dir2_files_list){

                    var button = new Gtk.Button.with_label (temp_file){ //button for open files
                        valign = Gtk.Align.BASELINE_CENTER
                    };
                    if(error_files_indexes.find (temp_index) != null){
                        button.add_css_class("destructive-action");
                        
                    } else {
                        button.add_css_class("suggested-action");
                    }
                    this.vbox_for_files.append (button);
                    temp_index++;

                    button.clicked.connect (()=>{
                        create_window_with_file_contents (button.get_label ());
                    });

                }
            }
        } catch (Error e) {
            print("Error while comparing directories: %s\n", e.message);
        }
        }



        private void create_window_with_file_contents(string file){ //open file
            FileIntegrityChecker.FileUtils fileutil = new FileIntegrityChecker.FileUtils();
            this.dir1_files_list = new List<string>();
                foreach (var item in comparator.dir1_files_list){
                    dir1_files_list.append (item); //dir1_files_list
                }

            string initial_file = "";
                string source_filename = File.new_for_path(file).get_basename();
                foreach (string target_path in dir1_files_list) { //foreach to get second dir
                    string target_filename = File.new_for_path(target_path).get_basename();
                    if (source_filename == target_filename) {
                        initial_file = target_path;
                    }
                }

            string[] file_with_errors = fileutil.compare_files_lines (initial_file, file);


            List<int> error_lines_list = new List<int>();
            foreach (var item in fileutil.error_lines){
                error_lines_list.append(item);
            }

            var new_window = new Gtk.Window();
            new_window.title = file;
            new_window.set_default_size(1600, 900);

            var scrolled_window = new Gtk.ScrolledWindow();
            new_window.set_child(scrolled_window);
            
            var hbox = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 5);
            scrolled_window.set_child(hbox);

            text_view = new Gtk.TextView(); //error file
            text_view.hexpand = true;
            text_view.editable = false;
            text_view.buffer.changed.connect(() => update_line_numbers());

            text_view1 = new Gtk.TextView(); //initial file
            text_view1.hexpand = true;
            text_view1.editable = false;
            text_view1.buffer.changed.connect(() => update_line_numbers());

            var buffer = text_view.buffer;
            buffer.text = "Strings with errors - ";
            foreach (var item in error_lines_list){
                buffer.text += item.to_string ("%i ");
            } 
            
            buffer.text += file_with_errors[1]; //!!!!!!!!!!!!!!!!!!!!!!!!!

            var buffer1 = text_view1.buffer;
            buffer1.text = "Initial file\n" + file_with_errors[0];

            line_number_label = new Gtk.Label("");
            line_number_label.hexpand = false;
            line_number_label.set_wrap (true);
            line_number_label.set_valign(Gtk.Align.START);
            line_number_label.set_halign(Gtk.Align.START);
            line_number_label.set_margin_end(0);

            hbox.append(line_number_label);
            hbox.append(text_view);
            hbox.append(text_view1);
            
            update_line_numbers ();
            new_window.present();
        }

        private void update_line_numbers(){ //init line number`s
            var line_count = text_view.buffer.get_line_count();
            var numbers = new StringBuilder();
            for (int i = 0; i <= line_count; i++) {
                numbers.append(i.to_string() + "\n");
            }
            line_number_label.set_text(numbers.str);
        }

        public static int main (string[] args) {
            var app = new CBF ();
            return app.run (args);
        }
    }
