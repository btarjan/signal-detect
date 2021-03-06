function [DM,SRO,TK,T] = illustrate_match(DQ,SR,FL,IX,FN)
% [DM,SRO,TK,T] = illustrate_match(DQ,SR,FL,IX)
%     Show graphically which landmarks led to a match.
%     DQ @ SR is the waveform of the query.
%     FL is cell array giving the filenames for the elements in the
%     database.
%     Runs the query, then shows specgrams of query (with
%     landmarks) and the IX'th hit (with landmarks), highlighting the
%     matches.  IX defaults to 1.
%     DM returns the waveform of the matching audio, at sampling
%     rate SRO.
% 2008-12-30 Dan Ellis dpwe@ee.columbia.edu

if nargin < 4;  IX = 1; FN='Query audio'; end

if ischar(DQ)
  [DQ,SR] = readaudio(DQ);
end

% Run the query
[R,Lm] = match_query(DQ,SR,IX);

%R
%Lm
%size(Lm)

% Lm returns the matching landmarks in the original track's time frame
% Filter to be only those consistent with modal dt (+/- 1 step)
if (size(Lm,1)==0)
  return
end
  
Lm = Lm( abs(Lm(:,5)-R(IX,3)) < 1 ,:);

% Recalculate the landmarks for the query
dens = 7;
Lq = find_landmarks(DQ,SR,dens);
% Plot them
subplot(211)
show_landmarks(DQ,SR,Lq);

% Recalculate landmarks for the match piece
tbase = 0.032;  % time base of analysis

matchtrk = R(IX,1);
matchdt = R(IX,3);
[d,SRO] = readaudio(FL{matchtrk});
Ld = find_landmarks(d,SRO,dens);
% Plot them, aligning time to the query
subplot(212)
show_landmarks(d,SRO,Ld,matchdt*tbase + [0 length(DQ)/SR]);
mbase = 1 + round(matchdt*tbase*SRO);
mend = mbase - 1 + round(length(DQ)*SRO/SR);
DM = [zeros(1,max(0,-(mbase-1))), d(max(1,mbase):mend)];
[p,name,e] = fileparts(FL{matchtrk});
name(find(name == '_')) = ' ';
title(['Match: ',name,' at ',num2str(matchdt*tbase),' sec']);

% Highlight the matching landmarks
show_landmarks([],SRO,Lm,[],'o-g');
subplot(211)
 show_landmarks([],SRO,Lm-repmat([matchdt 0 0 0 0],size(Lm,1),1),[],'o-g');

set (get (gca, "title"), "interpreter", "none");
title(FN)

TK = matchtrk;
T = matchdt;
