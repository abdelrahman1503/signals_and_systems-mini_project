%% Reading the sampling frequency and validating it
f_sampling = input("Please enter the sampling frequency of the signal: ");
while f_sampling <= 0
    fprintf("\t*** Invalid Input ***\t\n");
    f_sampling = input("Please enter the sampling frequency of the signal: ");
end
%% Reading the start and end time and the number of breakpoints
t_start = input("Please enter the start of the time scale: ");
t_end = input("Please enter the end of the time scale: ");
bp_number = input("Please enter the number of breakpoints: ");
%% Validating number of breakpoints
while bp_number < 0 || round(bp_number) ~= bp_number
    fprintf("\t*** Invalid Input ***\t\n");
    input("Please enter the number of breakpoints: ");
end
%% Setting breakpoint times
prev_time = t_start;
bp_times = zeros(1, bp_number);
for i = 1 : bp_number
    bp_t = input(sprintf('Enter the time of breakpoint number %d: ', i));
    while bp_t <= prev_time || bp_t >= t_end
        fprintf("\t*** Invalid Input ***\t\n");
        bp_t = input(sprintf('Enter the time of breakpoint number %d: ', i));
    end
    if bp_t * f_sampling ~= round(bp_t * f_sampling)
        bp_t = ceil(bp_t(i) * f_sampling) / f_sampling;
    end
    prev_time = bp_t;
    bp_times(i) = bp_t;
end
t_points = [t_start bp_times t_end];
t_var = cell(1, length(t_points)-1);
f_t = cell(1, length(t_points)-1);
%% Giving definition for each region
for j = 1 : length(t_points)-1
    t_s = t_points(j);
    t_e = t_points(j+1);
    t_var{j} = linspace(t_s , t_e, ( t_e - t_s ) * f_sampling);
    fprintf('Region %d\n', j);
    fprintf('1-DC signal\n2-Ramp signal\n3-General Order polynomial\n4-Exponential Signal\n5-Sinusoidal Signal\n6-Sinc function\n7-Triangle Pulse\n');
    answer = input('Please enter the number corresponding to your choice: ');
    switch answer
         case 1
            amp = input(sprintf('DC Signal Amplitude: '));
            f_t{j} = amp + 0 * t_var{j};
        case 2
            slope = input(sprintf('Ramp Signal Slope: '));
            intercept = input(sprintf('Ramp Signal Intercept: '));
            f_t{j} = slope * t_var{j} + intercept;
        case 3
            order = input(sprintf('GOP Signal Order: '));
            while order < 1 || order ~= round(order)
                fprintf("\t*** Invalid Input ***\t\n");
                order = input(sprintf('GOP Signal Order: '));
            end
            f_t{j} = zeros(1, length(t_var{j}));
            for k = order:-1:1
                amp = input(sprintf('t^%d Amplitude: ', k));
                f_t{j} = f_t{j} + amp * t_var{j} .^ k ;
            end
            intercept = input(sprintf('GOP Signal Intercept: '));
            f_t{j} = f_t{j} + intercept;
        case 4
            amp = input(sprintf('Exponential Signal Amplitude: '));
            exponent = input(sprintf('Exponential Signal Exponent: '));
            f_t{j} = amp * exp( exponent * t_var{j});
        case 5
            amp = input(sprintf('Sinusoidal Signal Amplitude: '));
            freq = input(sprintf('Sinusoidal Signal Frequency: '));
            while freq <=0
                fprintf("\t*** Invalid Input ***\t\n");
                freq = input(sprintf('Sinusoidal Signal Frequency: '));
            end
            phase_s = input(sprintf('Sinusoidal Signal Phase: '));
            f_t{j} = amp * sin( 2 * pi * freq * t_var{j} + phase_s);
        case 6
            amp = input('Please enter the amplitude of the function: ');
            center_s = input('Please enter the center shift: ');
            center_s = center_s + t_s;
            f_t{j} = amp * sinc(t_var{j} - center_s);
        case 7
            amp = input('Please enter the amplitude of the function: ');
            center_s = input('Please enter the center shift: ');
            width = input('Please enter the width of the signal: ');
            center_s = center_s + t_s;
            f_t{j} = triangularPulse(center_s - width/2, center_s, center_s + width/2, t_var{j});
    end
end
%% plotting the orginal signal without operations
t = [ ];
for j = 1 : length(t_var)
    t = [ t t_var{j}(1:end) ];
end
 t = [ t t_var{end}(end) ];
 
x = [ ];
for j = 1 : length(f_t)
    x = [ x f_t{j}(1:end) ];
end
x = [ x f_t{end}(end) ];

figure;
plot(t, x);
%% Signal operations
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