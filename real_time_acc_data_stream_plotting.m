%% Real Time Data Stream and Plotting Example
function real_time_data_stream_plotting
% Create a TCPIP object listening to port 50007.
interfaceObject = tcpip('localhost',50007);

% Create x,y,z FIFOs
asyncXBuff  = dsp.AsyncBuffer(1000); 
asyncYBuff  = dsp.AsyncBuffer(1000); 
asyncZBuff  = dsp.AsyncBuffer(1000); 

% Define a callback function to be executed when desired number of bytes are available in the input buffer
interfaceObject.BytesAvailableFcn = {@localRead,asyncXBuff,asyncYBuff,asyncZBuff};
% A bytes-available event occurs when a terminator is read, as determined by the BytesAvailableFcnMode property.
interfaceObject.Terminator = '}';
interfaceObject.BytesAvailableFcnMode = 'terminator';

% Open the interface object
fopen(interfaceObject);

% Get some data from socket (python server)
pause(15);

% Download data from FIFOs into arrays
outx = zeros(1,1000);
outy = zeros(1,1000);
outz = zeros(1,1000);
index = 0;
while index < asyncXBuff.NumUnreadSamples
    outx = peek(asyncXBuff,index);
    outy = peek(asyncYBuff,index);
    outz = peek(asyncZBuff,index);
    index=index+1;
end

% Plot x,y,z, accelerometer data
hold on;
%plot3(outx,outy,outz,'b');
plot(outx,'r')
plot(outy,'g')
plot(outz,'b')

% Clean up the interface object
hold off;
pause(1);
fclose(interfaceObject);
delete(interfaceObject);
clear interfaceObject;
disp('End of program');

%% Implement buffer callback
function localRead(interfaceObject,~,asyncXBuff,asyncYBuff,asyncZBuff)
% Read the json incoming from socket
data = fscanf(interfaceObject);
% DEBUG
%disp(data);
% Decode json
temp = jsondecode(data);
% Push data to FIFOs
write(asyncXBuff,temp.x);
write(asyncYBuff,temp.y);
write(asyncZBuff,temp.z);