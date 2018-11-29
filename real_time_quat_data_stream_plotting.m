%% Real Time Data Stream and Plotting Example
function real_time_data_stream_plotting
% Create a TCPIP object listening to port 50007.
interfaceObject = tcpip('localhost',50007);

% Global variables
global yaw_c
global pitch_c
global roll_c
yaw_c = 0;
pitch_c = 0;
roll_c = 0;

% Visualize Data On Sphere Or any Other Objects
[x,y,z] = sphere;
h = surf(x,y,z);
axis([-1.5 1.5 -1.5 1.5 -1.5 1.5])
%axis('square'); 
hold on

% Start the drawing
title('3D Motion')
xlabel('x'); 
ylabel('y'); 
zlabel('z');

% Define a callback function to be executed when desired number of bytes are available in the input buffer
interfaceObject.BytesAvailableFcn = {@localRead,h};
% A bytes-available event occurs when a terminator is read, as determined by the BytesAvailableFcnMode property.
interfaceObject.Terminator = '}';
interfaceObject.BytesAvailableFcnMode = 'terminator';

% Open the interface object
fopen(interfaceObject);

% Get some data from socket (python server)
pause(15);

% Clean up the interface object
hold off;
pause(1);
fclose(interfaceObject);
delete(interfaceObject);
clear interfaceObject;
disp('End of program');

%% Implement buffer callback
function localRead(interfaceObject,~,h)
% Global variables
global yaw_c
global pitch_c
global roll_c
% Read the json incoming from socket
data = fscanf(interfaceObject);
% Debug statement
%disp(data);
% Decode json
temp = jsondecode(data);
% Convert Quaternion to Roll Pitch Yaw
%[yaw, pitch, roll] = quat2angle([temp.z temp.y temp.x temp.w],'ZYX');
yaw = temp.yaw;
pitch = temp.pitch;
roll = temp.roll;
% Rotate Object
rotate(h,[1,0,0],(roll-roll_c));
rotate(h,[0,1,0],(pitch-pitch_c));
rotate(h,[0,0,1],(yaw-yaw_c));
yaw_c = yaw;
pitch_c = pitch;
roll_c = roll;
% Draw sphere
drawnow;

