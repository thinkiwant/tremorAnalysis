function nearByCh = getNearByCh(cur, nth)
% cur is the current order of the channel
% nth is th nth nearby channel of cur to return

electrodeArrangment = [ 4, 5,11,10,24,32,34,39,40,49,50,62,61;
                        3, 6,12, 9,23,31,33,38,48,41,51,63,60;
                        2, 7,13,17,22,30,27,37,47,42,52,64,59;
                        1, 8,14,18,21,29,26,36,46,43,53,56,58;
                       -1,16,15,19,20,28,25,35,45,44,54,55,57];
relativePosition =[[-1,0];[1,0];[0,-1];[0,1];[-1,-1];[-1,1];[1,-1];[1,1]];
[cX, cY] = find(electrodeArrangment==cur);
ci = 0;
nearByCh = -1;
for i=1:length(relativePosition)
    nX = cX+relativePosition(i,1);
    nY = cY+relativePosition(i,2);
    if(nX <1 || nY<1 || nX>size(electrodeArrangment,1) || nY >size(electrodeArrangment,2) || (nX==5 && nY == 1))
        continue;
    end
    if(ci==nth)
        nearByCh = electrodeArrangment(nX, nY);
        break;
    end
    ci=ci+1;
end
if(nearByCh<0)
    warning("failed to find nearby channel");
end

end


                   