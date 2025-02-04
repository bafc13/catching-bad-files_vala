

int main(string []argv){
    stdout.printf("%s argv0, %s argv1, %s argv2 \n",argv[0],argv[1],argv[2]);
    if(argv[2] == null){
        stdout.printf("Write all directories\n");
        return 0;
    }
    FileIntegrityChecker.FileComparator comparator = new FileIntegrityChecker.FileComparator(argv[1],argv[2]);
    //  char *filename_1 = argv[0]; //from where u gona check control summ
    //  char *filename_2 = argv[1]; //file that u need to compare
    comparator.compare_directories();
    stdout.printf("\nCheckout for report in file log");

    return 0;
}


