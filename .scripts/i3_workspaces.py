#!/usr/bin/env python
#======================================================================
# i3 (Python module for communicating with i3 window manager)
# Modified from wsbar.py from the i3py examples directory.
# Copyright (C) 2012 Jure Ziberna
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#======================================================================


import sys
import time
import subprocess

import i3

class i3wsbar(object):
    def __init__(self):
        # Initialize the socket
        self.socket = i3.Socket()

        # Immediately send the workspaces to stdout.
        workspaces_soc = self.socket.get('get_workspaces')
        outputs_soc = self.socket.get('get_outputs')
        self.add_states(workspaces_soc, outputs_soc)
        self.workspaces = workspaces_soc
        self.display()

        # Subscribe to `workspace` event
        callback = lambda data, event, _: self.change(data, event)
        self.subscription = i3.Subscription(callback, 'workspace')

    def change(self, event, workspaces):
        '''
        Receives event and workspace data, displays on stdout if change is
        present in event.
        '''
        if 'change' in event:
            outputs = self.socket.get('get_outputs')
            self.add_states(workspaces, outputs)
            self.workspaces = workspaces

    def add_states(self, workspaces, outputs):
        '''
        Adds state data to each workspace. The states include:
            - focused
            - active (when a workspace is opened on unfocused output)
            - inactive (unfocused workspace)
            - urgent
        Se more in the `get_state()` docstring.
        '''
        for workspace in workspaces:
             output = self.find_output(workspace, outputs)
             # Appending an element onto the internal workspace
             # dictionary is not great, but it keeps all the data
             # pertaining to each workspace in one place.
             workspace['state'] = self.get_state(workspace, output)

    def get_state(self, workspace, output):
        '''
        Returns the state of a workspace as a uppercase
        three character abbreviation:
            - Focused workspace        FOC
            - Active workspace         ACT
            - Inactive workspace       INT
            - Urgent workspace         URG
        '''
        if workspace['focused']:
            # output may be None, but should only be so when the
            # workspace state is not active (urgent, inactive, etc).
            # Therefore, the statement above should guard against this.
            if output['current_workspace'] == workspace['name']:
                # Focused workspace
                return 'FOC'
            else:
                # Active workspace
                return 'ACT'
        if workspace['urgent']:
            # Urgent workspace
            return 'URG'
        else:
            # Inactive workspace
            return 'INT'

    def find_output(self, workspace, outputs):
        for output in outputs:
            if output['name'] == workspace['output']:
                return output

    def display(self):
        '''
        Writes all workspace names and states on stdin.
        '''
        ws_txt = ''
        for ws in self.workspaces:
            ws_txt += '%s\t%s\t' % (ws['name'], ws['state'])
        ws_txt += '\n'
        sys.stdout.write(ws_txt)
        sys.stdout.flush()

    def quit(self):
        '''
        Quits the i3wsbar; closes the subscription and terminates the bar
        application.
        '''
        self.subscription.close()


if __name__ == '__main__':
    bar = i3wsbar()
    try:
        while True:
            time.sleep(1)
            bar.display()
    except KeyboardInterrupt:
        print('')  # force new line
    finally:
        bar.quit()
