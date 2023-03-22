%% Reading the sampling frequency and checking it
f_sampling = input("Please enter the sampling frequency of the signal: ");
while f_sampling <= 0
    fprintf("\t*** Invalid Input ***\t\n");
    f_sampling = input("Please enter the sampling frequency of the signal: ");
end
%% Reading the start and end time and the number of breakpoints
t_start = input("Please enter the start of the time scale: ");
t_end = input("Please enter the end of the time scale: ");
bp_number = input("Please enter the number of breakpoints: ");
%% Validating the number of breakpoints
while is_not_valid_bp(bp_number)
    fprintf("\t*** Invalid Input ***\t\n");
    input("Please enter the number of breakpoints: ");
end
%% setting the breakpoints time
breakpoints_times = t_start * ones(1, bp_number);
t_last = t_start;
for i = 1: bp_number
    
    t_bp_time = input(sprintf('Break point #%d time: ', i));
    t_bp_time = allign_to_sample_point(t_bp_time, f_sampling);
   
    while is_not_valid_pbtime(t_bp_time, t_last, t_end)
        disp("Invalid input please try again....");
        t_bp_time = input(sprintf('Break point #%d time: ', i));
        t_bp_time = allign_to_sample_point(t_bp_time, f_sampling);
    end
    breakpoints_times(i) = t_bp_time;
    t_last = t_bp_time;
end
time_points = [ t_start      breakpoints_times     t_end];
lin_spaces = cell(1,length(time_points)-1) ;                                                              
function_points = cell(1,length(time_points)-1) ; 
%% definning each region
for j = 1 : length(time_points)-1
    t_s = time_points(j);
    t_e = time_points(j+1);
    lin_spaces{j} = linspace(t_s , t_e, ( t_e - t_s ) * f_sampling);
    fprintf('What is this region:\n1-DC signal\n2-Ramp signal\n3-General Order polynomial\n4-Exponential Signal\n5-Sinusoidal Signal\n6-Sinc function\n7-Triangle Pulse\n');
    answer = input('Please enter the number corresponding to your choice: ');
    switch answer
         case 1
            amp = input(sprintf('DC Signal Amplitude: '));
            function_points{j} = amp + 0 * lin_spaces{j};
        case 2
            slope = input(sprintf('Ramp Signal Slope: '));
            intercept = input(sprintf('Ramp Signal Intercept: '));
            function_points{j} = slope * lin_spaces{j} + intercept;
        case 3
            order = input(sprintf('GOP Signal Order: '));
            while order < 1 || order ~= round(order)
                fprintf("\t*** Invalid Input ***\t\n");
                order = input(sprintf('GOP Signal Order: '));
            end
            function_points{j} = zeros(1, length(lin_spaces{j}));
            for k = order:-1:1
                amp = input(sprintf('t^%d Amplitude: ', k));
                function_points{j} = function_points{j} + amp * lin_spaces{j} .^ k ;
            end
            intercept = input(sprintf('GOP Signal Intercept: '));
            function_points{j} = function_points{j} + intercept;
        case 4
            amp = input(sprintf('Exponential Signal Amplitude: '));
            exponent = input(sprintf('Exponential Signal Exponent: '));
            function_points{j} = amp * exp( exponent * lin_spaces{j});
        case 5
            amp = input(sprintf('Sinusoidal Signal Amplitude: '));
            freq = input(sprintf('Sinusoidal Signal Frequency: '));
            while freq <=0
                fprintf("\t*** Invalid Input ***\t\n");
                freq = input(sprintf('Sinusoidal Signal Frequency: '));
            end
            phase_s = input(sprintf('Sinusoidal Signal Phase: '));
            function_points{j} = amp * sin( 2 * pi * freq * lin_spaces{j} + phase_s);
        case 6
            amp = input('Please enter the amplitude of the function: ');
            center_s = input('Please enter the center shift: ');
            center_s = center_s + t_s;
            function_points{j} = amp * sinc(lin_spaces{j} - center_s);
        case 7
            amp = input('Please enter the amplitude of the function: ');
            center_s = input('Please enter the center shift: ');
            width = input('Please enter the width of the signal: ');
            center_s = center_s + t_s;
            function_points{j} = triangularPulse(center_s - width/2, center_s, center_s + width/2, lin_spaces{j});
    end
end
%% plotting the orginal signal without operations
t = [ ];
for j = 1 : length(lin_spaces)
    t = [ t lin_spaces{j}(1:end) ];
end
 t = [ t lin_spaces{end}(end) ];
 
x = [ ];
for j = 1 : length(function_points)
    x = [ x function_points{j}(1:end) ];
end
x = [ x function_points{end}(end) ];

figure;
plot(t, x);
%% signal operations
flag = 1;
while flag ~= 0
    fprintf("Choose an operation:\n1-Amplitude Scaling\n2-Time Reversal\n3-Time Shift\n4-Expanding the Signal\n5-Compressing the Signal\n6-Clipping the signal\n7-The First Derivative of the signal\n8-No operation\n");
    answer = input('Please enter the number corresponding to your choice: ');

    switch answer
        case 1
            t_S = input('Scale Value: ');
            x = t_S * x;
        case 2
            t = -t;
        case 3
            t_SH = input('Shift Value X[ t - T ]: ');
            t = t + t_SH ;
        case 4
            expand = input('Expanding Value ]0 , 1[ : ');
            while expand <=0 || expand >=1
                fprintf("\t*** Invalid Input ***\t\n");
                expand = input('Expanding Value ]0 , 1[ : ');
            end
            t = t / expand ;
        case 5
            t_C = input('Compressing Value ]1 , inf[ : ');
            while t_C <=1
                fprintf("\t*** Invalid Input ***\t\n");
                t_C = input('Compressing Value ]1 , inf[ : ');
            end
            t = t / t_C ;
        case 6
            clip_u = input('Enter the upper limit: ');
            clip_l = input('Enter the lower limit: ');
            while clip_u > max(x) || clip_l < min(x)
                fprintf("\t*** Invalid Input ***\t\n");
                clip_u = input('Enter the upper limit: ');
                clip_l = input('Enter the lower limit: ');
            end
            for i = 1 : length(x)
                if x(1, i) > clip_u
                    x(1, i) = clip_u;
                elseif x(1, i) < clip_l
                    x(1, i) = clip_l;
                end
            end
        case 7
            x = diff(x);
            x(end + 1) = x(end);
        case 8
            flag = 0;
    end
    
    if flag == 1
        figure;
        plot(t, x);
        
    end
end
%% functions
function y = is_not_valid_bp(bp_number)
    y =  bp_number < 0 || round(bp_number) ~= bp_number;                                                                                          
end

function y = allign_to_sample_point(pbtime, sf)
     y = pbtime;
    if pbtime * sf ~= round(pbtime * sf)
        y = ceil(pbtime * sf) / sf;
    end
end

function y = is_not_valid_pbtime( pbtime, prev_time, end_)             
y =  pbtime <= prev_time || pbtime >= end_;
end

