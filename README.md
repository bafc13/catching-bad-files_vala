**catching-bad-files**

util for comparing files which can be bad (damaged). firstly comparing by md5 hash sum, and after that you can see the damaged places, strings

**Installation**

_Meson, gcc, cMake, make, vala, Gtk4, Gio-2.0, GObject-2.0, GLib-2.0_


sudo apt-get update

sudo apt-get install meson gcc cmake make vala libgtk4 libgtk4-devel libgio-2.0.so.0 libgobject-2.0.so.0 libglib-2.0.so.0


_Clone repo:_


git clone https://github.com/bafc13/catching-bad-files_vala.git

cd catching-bad-files_vala/src


_Compile lib:_


valac --library md5-compare -H md5-compare.h -C md5-compare.vala --pkg gio-2.0 --pkg glib-2.0

gcc -shared -fPIC -o libmd5-compare.so.1.0 -Wl,-soname,libmd5-compare.so.1 md5-compare.c $(pkg-config --cflags --libs gio-2.0 glib-2.0)

ln -T libmd5-compare.so.1.0 libmd5-compare.so.1

ln -T libmd5-compare.so.1 libmd5-compare.so


_Insert lib in /usr/lib/_


sudo mv libmd5-compare.so libmd5-compare.so.1 libmd5-compare.so.1.0 /usr/lib


_Init build dir_


cd ..

meson setup build

cd build


_Compile_


meson configure --sharedstatedir SHAREDSTATEDIR

meson compile



**Using**

to use write in console:


./catch-bad-files


Click button Open initial directory and choose serviceable directory, click button Open bad directory and choose directory that you think is damaged. After that press button Start compare. Programm will print list of paths, red ones - damaged. Click on red button to see the initial and damaged file, in first string you would see the numbers of lines with error. Visit this lines to see the difference.

In addition to the application, a log is generated in the folder with the binary


**screenshots**
![изображение](https://github.com/user-attachments/assets/75db81f2-4a65-44a7-bc14-8d0c9790f0df)
![изображение](https://github.com/user-attachments/assets/409cddae-4af0-49e1-9886-e26af52626d8)
![изображение](https://github.com/user-attachments/assets/45bff39b-7d53-4a9a-a6c5-18ce43f1422a)
![изображение](https://github.com/user-attachments/assets/80fb9b0b-a28b-4686-a692-d94e03270856)


