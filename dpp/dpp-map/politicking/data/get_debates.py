#!/usr/bin/python
import os
import re
import format_debates

# This script takes awhile to run, mostly due to POS tagging in
# format_debates.  If you're in a hurry and have a few machines, you
# can comment out the code below the for-loop, split up this dates
# array (run just a few dates on each machine), then run the code
# below the for-loop on all the resulting output files.
dates = ['12-02-22', '12-01-26', '12-01-23', '12-01-19', '12-01-16', '12-01-08', '12-01-07', '11-12-15', '11-12-10', '11-11-22', '11-11-12', '11-11-09', '11-10-18', '11-10-11', '11-09-22', '11-09-12', '11-09-07', '11-09-05', '11-08-11', '11-06-13']
locs = ['99556', '99075', '99001', '98936', '98929', '98814', '98813', '97978', '97703', '97332', '97038', '97022', '96914', '96894', '96795', '96683', '96659', '96660', '90711', '90513']

start_pattern = re.compile('<b>PARTICIPANTS:</b>')
mid_pattern = re.compile('<p>')
end_pattern = re.compile('</span>')
for i in range(len(dates)):
  filename = dates[i] + '.txt'
  # os.system("wget -O " + filename + " \"http://www.presidency.ucsb.edu/ws/index.php?pid=\"" + locs[i])

  # fid = open(filename, 'r')
  # data = fid.read()
  # fid.close()

  # start = start_pattern.search(data).start()
  # mid = mid_pattern.search(data, start).start() + 3
  # mid = mid_pattern.search(data, mid).start() + 3
  # end = end_pattern.search(data, mid).start()
  # data = data[mid:end]
  
  # fid = open(filename, 'w')
  # fid.write(data)
  # fid.close()

  format_debates.main(['main', '-i', filename])

speeches = {}
speakers = ['BACHMANN', 'CAIN', 'GINGRICH', 'HUNTSMAN', 'PAUL', 'PERRY', 'ROMNEY', 'SANTORUM']
for i in range(len(dates)):
  date_pattern = re.compile(dates[i] + '.txt')
  files = os.listdir('.')
  for filename in files:
    date_match = date_pattern.search(filename)
    if date_match:
      speaker = filename[:date_match.start()-1]
      if speaker in speakers:
        if speaker not in speeches:
          speeches[speaker] = []
        speeches[speaker].append(open(filename, 'r').read())

for speaker in speeches:
  fid = open(speaker + '.txt', 'w')
  fid.write(''.join(speeches[speaker]))
  fid.close()
