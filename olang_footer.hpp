
}catch(const out_of_range& ex){
	cerr<<"On line "<<LINENO<<": Attempted use of non-allocated variable.\n\t This was not caught at compile time, because it is allocated somewhere in the logic tree above this point, but it wasn't in this run.\n";
}catch(const exception& ex){
	cerr<<"On line "<<LINENO<<": Strange exception thrown. Please contact the language's developer(s), as this was not forseen as a possibility. ex.what:"<<ex.what()<<'\n';
}catch(...){
	cerr<<"On line "<<LINENO<<": What on earth did you do? This shouldn't be remotely possible. I have no idea what to do. Aborting.\n";
}
}
