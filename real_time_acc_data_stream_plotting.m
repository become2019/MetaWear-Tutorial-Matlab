%% Real Time Data Stream and Plotting Example
function real_time_data_stream_plotting
% Create a TCPIP object listening to port 50007.
interfaceObject = tcpip('localhost',50007);

% Global variables
global counter;
counter = 0;

% Set up the figure window
x = 0;
y = 0;
figureHandle = figure;
hold on;
grid on;
plotHandle1 = plot(x,counter,'r');
plotHandle2 = plot(y,counter,'g');
plotHandle3 = plot(y,counter,'b');

% Define a callback function to be executed when desired number of bytes are available in the input buffer
interfaceObject.BytesAvailableFcn = {@localRead, plotHandle1, plotHandle2, plotHandle3};
% A bytes-available event occurs when a terminator is read, as determined by the BytesAvailableFcnMode property.
interfaceObject.Terminator = '}';
interfaceObject.BytesAvailableFcnMode = 'terminator';

% Open the interface object
fopen(interfaceObject);

% Get some data from socket (python server) for 15 seconds
pause(20);

% Clean up the interface object
hold off;
pause(1);
fclose(interfaceObject);
delete(interfaceObject);
clear interfaceObject;
disp('End of program');

%% Implement buffer callback
function localRead(interfaceObject,~,plotHandle1, plotHandle2, plotHandle3)
% Global variables
global counter;
% Read the json incoming from socket
data = fscanf(interfaceObject);
% DEBUG
%disp(data);
% Decode json
temp = jsondecode(data);
% Plot update
old_temp_x = get(plotHandle1, 'YData');
old_counter1 = get(plotHandle1, 'XData');
old_temp_y = get(plotHandle2, 'YData');
old_counter2 = get(plotHandle2, 'XData');
old_temp_z = get(plotHandle3, 'YData');
old_counter3 = get(plotHandle3, 'XData');
set(plotHandle1,'YData',[old_temp_x, temp.x],'XData',[old_counter1, counter]);
set(plotHandle2,'YData',[old_temp_y, temp.y],'XData',[old_counter2, counter]);
set(plotHandle3,'YData',[old_temp_z, temp.z],'XData',[old_counter3, counter]);
disp(counter);
disp(temp.x);
drawnow;
counter=counter+1;