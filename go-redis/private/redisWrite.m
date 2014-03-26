function status = redisWrite(R, varargin)

  fread (R,1e6,1); % flush

  [tmp,len] = cellfun (@createRedisStr,varargin,'UniformOutput',0);
  tmp = sprintf ('*%d\r\n%s', sum (cell2mat (len)), [tmp{:}]);
  fprintf (R,tmp);
  
end


function [outstr,celllen] = createRedisStr (inp)
  celllen = 1;
  if isnumeric (inp)

    if size (inp,2) ~= 1 && ndims (inp) == 2
      warning ('redis: only row vectors supported. forcing');
      inp = inp(:);
    end
    
    celllen = length(inp);
    
    if []
       % no vectorization unless fixed string length
      %inp = sprintf ('%5.1f\n', inp); 
      inp = num2str (inp, 16);
      inp = strsplit (inp);
      outstr = cellfun (@strhelper, inp, 'UniformOutput', 0);
      outstr = [outstr{:}];
    else
      % only for fixed string length
      inp = num2str (inp, 16);
      pre = sprintf ('$%d\r\n',size (inp,2));  % get length of line
      post = '\r\n';
      getlen = @(x,y)repmat(x,[y 1]);
      inp = [ getlen(pre,celllen) inp getlen(post,celllen) ];
      %outstr = inp'(:)';
      outstr = inp;
    end

  elseif ischar (inp)
    outstr = strhelper (inp);
  else
    error ('redis: input argument not supported')
  end
  

end


function outstr = strhelper (inp)
    outstr = sprintf ('$%d\r\n%s\r\n', length (inp), inp);   % not binary safe
end
