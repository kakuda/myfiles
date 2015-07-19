"""File name completion for python module of GNU readline

This module does completion for the filenames of
working directory.

The filename completion is done
if the last character of the line is \" or \'.
The exceptions are for r\" or r\'.
(They may be used for regular expression or something
 other than filenames.)
"""

import re, os, os.path, readline
__all__ = ['Completer']

class Completer:
    __instance = None

    def __init__(self, second=None) :
        """second : The second completer.
        If the text is not for file completion,
        all arguments will be given to second completer as they are.
        """
        self.__second = second
        pass

    def extract_file_part(self, text) :
        """Check if the text line is for file completion or not.
        If matches for the file completion,
        returns the filename part prefix (the part not included in \"text\")
        and the full filename part.
        Return \"None\" if \"text\" is not for file completion.
        """

        full_text = readline.get_line_buffer()
        # Remove quoted part.
        index = 0
        while 1:
            mo = re.search(r'(?:^|[^\\r])([\'\"])(?:.*?[^\\r])?\1',
                           full_text[index:])
            if not mo : break
    
            index = mo.end()
            pass

        # Find first " or '
        mo = re.search(r'(?:^|[^\\r])[\'\"]', full_text[index:])
        if mo :
            mo2 = re.search( '%s$' % text, full_text[mo.end():])
            return (full_text[mo.end():mo.end()+mo2.start()],
                    full_text[mo.end():])
        return None
    # ======== "devide_filepart" : End of definition ===========

    def whitespace_only_before_cursor(self):
        full_text = readline.get_line_buffer()
        for i in range(readline.get_endidx()):
            if full_text[i].strip()!='': return False
            pass
        return True
    
    def complete(self, text, state) :
        # Check if this text is for dealing by filecomplete
        if state == 0 :
            if self.extract_file_part(text) :
                self.deal_by_myself = 1
                pass
            else :
                self.deal_by_myself = 0
                pass
            pass

        # For "for XX in XXX:" or "def XXX():"
        if not self.deal_by_myself \
               and self.whitespace_only_before_cursor():
            if state==0: return '%s\t' % text
            return None

        # If this text is not for filecompletion, transfer
        if not self.deal_by_myself :
            if self.__second :
                return self.__second(text, state)
            else :
                return None
            pass

        # This text is for dealt by filecompletion
        if state == 0 :
            (file_part_prefix, file_part_full) = self.extract_file_part(text)
            self.matches = self.file_matches(file_part_prefix,
                                             file_part_full)
            pass
        try:
            return self.matches[state]
        except IndexError:
            return None
        pass
    # ======= "complete" : End of the definition =======


    def file_matches(self, file_part_prefix, file_part_full) :
        # First, extract the file, directory
        directory, file  = os.path.split( file_part_full )
        abs_directory    = os.path.abspath(os.path.expanduser(directory))
        # abs_directory = directory

        # Check if the directory exists or not
        if not os.path.isdir(abs_directory) : return None

        # Search and select filenames
        files_in_the_directory = os.listdir(abs_directory)

        retval = []
        file = re.sub(r'\.', r'\\.', file)
        for a_file in files_in_the_directory :
            if re.match(file, a_file) :
                if a_file[0]!='.' or len(file)!=0 :
                    # Remove prefix part
                    entry = os.path.join(directory, a_file)
                    mo = re.match(file_part_prefix, entry)
                    if mo :
                        retval.append( entry[mo.end():] )
                        pass
                    pass
                pass
            pass
        # ------------ End of the file loop --------------

        # If candidate is only one
        if len(retval)==1 :
            if os.path.isdir(retval[0]) :
                # If it is a directory
                retval.append( os.path.join(retval[0], '') )
                pass
            else :
                # If it is a file
                if len(file_part_prefix)!=0 :
                    retval[0] = retval[0] + readline.get_line_buffer()[-len(file_part_full)-1]
            pass
        return retval
    # ====== "file_matches" : End of the definition. ========
    
    pass
# End of the class definition.

readline.set_completer( Completer(readline.get_completer()).complete )
