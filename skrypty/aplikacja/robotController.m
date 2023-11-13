classdef robotController
    properties
        serialPort  = [];
        isConnected = false;
        debug       = false;
        showDialog  = false;
    end
    
    methods
        function [obj, res] = connect(obj, port, baudrate)
            res = false;
             try
                obj.serialPort = serialport(port, baudrate);
                configureTerminator(obj.serialPort,"CR")
            catch ex
                msgbox(ex.message, "Błąd!", "error");
                obj.isConnected = false;
                return;
             end
            obj.isConnected = true;
            % initial codes
            obj.sendGCodeToRobot(" ");
            obj.sendGCodeToRobot(" ");
            obj.sendGCodeToRobot(" ");
            obj.sendGCodeToRobot("G21");    % jednostki mm
            obj.sendGCodeToRobot("G91");    % pozycja relatywna

            res = true;
        end
        function response = sendGCodeToRobot(obj, command)
            response = '';
            if ~obj.isConnected
                if  obj.showDialog
                    msgbox("Nie polaczono z robotem!", "Błąd!!", "error");
                end
                return;
            end

            try
                writeline(obj.serialPort, command);
                response = readline(obj.serialPort);
            catch ex
                obj.isConnected = false;

                if  obj.showDialog
                    msgbox(ex.message, "Błąd!!", "error");
                end
                return; 
            end
            fprintf("[SEND GCODE] cmd=> %s, res => %s \n", command, response);
        end
    end
end