using Gtk;


public class CBF : Gtk.Application {
    private Gtk.TextView text_view;
    private Gtk.ApplicationWindow window;
    private Gtk.Box vbox_for_files;
    private string dir1_path;
    private string dir2_path;
    public List<string> dir2_files_list;

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

        

        //  this.text_view = new Gtk.TextView () {
        //      editable = false,
        //      cursor_visible = false,
        //  };

        var scroll_view = new Gtk.ScrolledWindow () {
            hscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            vscrollbar_policy = Gtk.PolicyType.AUTOMATIC,
            vexpand = true,
            valign = Gtk.Align.FILL,
            child = this.text_view
        };

        var vbox = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
        vbox.append (toolbar);
        vbox_for_files = new Gtk.Box (Gtk.Orientation.VERTICAL, 0){

        };
        
        //  vbox_for_files.append (text_view);
        //  vbox.append (hbox);
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
                FileIntegrityChecker.FileComparator comparator = new FileIntegrityChecker.FileComparator(dir1_path,dir2_path);
                comparator.compare_directories();
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
                    print("Error while generating log, can't open log\n");
                }
                int temp_index = 0;
                foreach(var temp_file in dir2_files_list){ //по индексу из массива индексов ошибок пихаем красный цвет
                    var button = new Button.with_label (temp_file){
                        valign = Gtk.Align.BASELINE_CENTER
                    };
                    
                    var css_provider = new CssProvider();
                    if(error_files_indexes.find (temp_index) != null){
                        css_provider.load_from_data((uint8[])"#green_button { background-color: green; color: white; }");
                    } else {
                        css_provider.load_from_data((uint8[])"#red_button { background-color: red; color: white; }");
                    }
                    button.get_style_context().add_provider(css_provider, STYLE_PROVIDER_PRIORITY_USER);

                    this.vbox_for_files.append (button);
                    temp_index++;
                }
                
            }
            
        } catch (Error e) {
            print("Error while generating log: %s\n", e.message);
        }


            
        }

        public static int main (string[] args) {
            var app = new CBF ();
            return app.run (args);
        }

    }