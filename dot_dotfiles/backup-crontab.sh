#0 19 * * * /sbin/shutdown -h now
#0 1 * * * /sbin/shutdown -h now
#0 20 * * * /sbin/shutdown -s now
#5 20 * * * /sbin/shutdown -s now
#0 0 * * * /sbin/shutdown -h now
0 23 * * * /sbin/shutdown -s now
0 10 * * * open -a Google\ Chrome 'https://habitica.com/'
30 20 * * * open -a Google\ Chrome 'https://habitica.com/'
0 23 * * * open -a Freedom
30 23 * * * open -a Freedom
0 0 * * * open -a Freedom
0 16 * * * zsh -ic "configpush"
0 16 * * * zsh -ic "pushnotes"

