function mainLoop(timer, ev, app)
    imgSize = app.data.inputSize(1:2);
    timeStart = tic;
    frame = (snapshot(app.cam));
    frame = imresize(frame, imgSize);
    if(app.data.isColor == 0)
        frame = rgb2gray(frame);
    end

    if app.TrybledzeniaCheckBox.Value == 1
        frame = sledzenie(timer, ev, app, frame);
    else 
        frame = proste(timer, ev, app, frame);
    end

    frame = insertShape(frame, "rectangle", [imgSize(1)/2 - 15, imgSize(2)/2 - 15, 30, 30], "Color","red");
    if(app.data.isColor == 0)
        frame = cat(3, frame, frame, frame);
    end
    app.Image.ImageSource = frame;
end
function [app, frame, bboxes, scores, labels] = getBoxPos(app, frame)
    timeStart = tic;
    % detekcja 
    app.wykryteTextArea.Value = ["Brak"];
    [bboxes, scores, labels] = detect(app.data.detector, frame);
    if(app.data.isColor == 0)
        frame = cat(3, frame, frame, frame);
    end

    if isempty(labels) == 0
        headers = [];
        for ii=1:length(labels)
            headers = [headers sprintf("%s: %0.2f", labels(ii), scores(ii))];
        end
        frame = insertObjectAnnotation(frame,"rectangle",bboxes,headers, 'FontSize', 8);    
        app.wykryteTextArea.Value = string(labels);
    end
    timeEcl = toc(timeStart);
    str = sprintf("%0.5fs", timeEcl);
    app.CzasprzetwarzaniaEditField.Value = str;
end
function frame = sledzenie(timer, ev, app, frame)
    [app, frame, bboxes, scores, labels] = getBoxPos(app, frame);
    % wylicz przesuniecie
    imgSize = app.data.inputSize(1:2);
    if(~isempty(bboxes))
        ind = find(strcmp(string(labels), app.KlasyDropDown.Value));
        
        if app.robot.isConnected && ~isempty(ind)
            % x, y, width, height
            box = bboxes(ind, :);
            score = scores(ind);
            centerBox = [box(1) + 0.5*box(3), box(2) + 0.5*box(4)];
            error = imgSize./2 - centerBox;
            p = error .* [-0.4, 0.4];
            for i=1:length(p)
                if(p(i) > 0)
                    p(i) = min([6, round(p(i))]);
                else
                    p(i) = max([-6, round(p(i))]);
                end
            end
            
            app.robot.sendGCodeToRobot("G80");
            cmdToSend = sprintf("G1 X%2.2f Y%2.2f F%i", p(1), p(2), 2000);
            res = app.robot.sendGCodeToRobot(cmdToSend);       
        end
    end
end
function frame = proste(timer, ev, app, frame)
    imgSize = app.data.inputSize(1:2);
    if isempty(app.selectedPosFromYOLO)
        
        [app, frame, bboxes, scores, labels] = getBoxPos(app, frame);
        if isempty(labels) == 0
            ind = find(strcmp(string(labels), app.KlasyDropDown.Value));
            % wyznaczenie komendy wyslanej do robota
            if ~isempty(ind)
                app.selectedPosFromYOLO = ind;
                if app.robot.isConnected
                    % x, y, width, height
                    box = bboxes(ind, :);
                    score = scores(ind);
                    centerBox = [box(1) + 0.5*box(3), box(2) + 0.5*box(4)];
                    error = imgSize./2 - centerBox;
                    pp = [str2double(app.nastawaP1EditField.Value), str2double(app.nastawaP2EditField.Value)];
                    p = error .* pp;
        
                    cmdToSend = sprintf("G1 X%2.2f Y%2.2f F%i", p(1), p(2), 1500);
                    res = app.robot.sendGCodeToRobot(cmdToSend);       
                end
                app.YOLOStop();
            end
        end
    end
end
