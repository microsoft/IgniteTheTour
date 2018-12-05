import os
from pathlib import Path
from azureml.core.run import Run

def check_dir(path):
    if not os.path.exists(path):
        os.makedirs(path)
    return Path(path).resolve()

def log(file, format, *args, **kwargs):
    if not isinstance(file, Path):
        if args:
            print(format.format(*args))
        if kwargs:
            print(format.format(**kwargs))
    else:
        if file.is_file():
            f = open(file, 'a')
        else:
            f = open(file, 'w')

        if args:
            f.write(format.format(*args)+'\n')
        if kwargs:
            f.write(format.format(**kwargs)+'\n')

        f.close()

def aml_log(run, **kwargs):
    if run != None:
        for key, value in kwargs.items():
            run.log(key, value)
    else:
        print('{}'.format(FormatDict(kwargs)))

class FormatDict:
    def __init__(self, dictionary):
        self.dictionary = dictionary
        self.max_key = max([len(l) for l in self.dictionary.keys()])
        self.max_val = max([len(str(l)) for l in self.dictionary.values()]) 

    def __format__(self, fmt):
        l = list(self.dictionary.items())
        s = []
        s.append('-'*(self.max_key + self.max_val + 7) + '\n' )
        for item in l:
            s.append('| {k:<{kw}} | {v:<{vw}} |\n'.format(k=str(item[0]), 
                                        kw=self.max_key, 
                                        v=str(item[1]), 
                                        vw=self.max_val))
        s.append('-'*(self.max_key + self.max_val + 7) + '\n' )
        return ''.join(s)


if __name__ == '__main__':
    d = { 'test1': 4, 'superlong': 'week', 'small': 12.234 }
    p = FormatDict(d)
    print('D:\n{}'.format(p))
