%% Simple SPBC Model File
%
% This is a model file for a simple sticky-price business model. The model
% file describes variables, parameters and equations. Note that the model
% file does not specifies the tasks that will be performed with the model.
% The tasks will be set up in separate m-files, using standard Matlab
% functions and IRIS functions.
%
% Model files themselves cannot be executed. Instead, they are read in and
% converted into model objects by the IRIS function |model( )|. This is
% shown in <read_model.html read_model>.
%

%% Declare Variables, Shocks, Parameters
%
% Use single-quoted text preceding the respective name to annotate the
% variablews, shocks, or parameters.  These descriptions are stored in the
% resulting model object as well.

!transition_variables

    'Output' Y, 'Labor' N, 'Wage rate' W
    'Nominal Marginal Cost' Q, 'Consumption Habit' H, 'Productivity' A
    'Rate of Change in Productivity' dA
    'Final Prices' P, 'Interest Rate' R,
    'Price of Capital' Pk
    'Rental Price of Capital' Rk
    'Households Shadow Value of Wealth' Lambda
    'Inflation Q/Q' dP, 'Inflation Y/Y' d4P, 'Wage Inflation Q/Q' dW
    'Real Marginal Cost' RMC
   
!transition_shocks

    'Consumption Demand Shock' Ey, 'Cost Push Shock' Ep, 
    'Productivity Shock' Ea, 'Policy Shock' Er
    'Wage Shock' Ew

!parameters

    'Long Run Growth !! \alpha' alpha, 'Discount !! \beta' beta, ...
    'Labor Share !! \gamma' gamma, 'Depreciation !! \delta' delta,
    k, pi, eta, psi
    
    'Habit !! \chi' chi, 'Wage Stickiness !! \xi_w' xiw,
    'Price Stickiness !! \xi_p' xip, rhoa, rhor, kappap, kappan

%
   
%% Declare Measurement Variables (Observables)

!measurement_variables

    'Short Term Rate' Short, 'Price Inflation' Infl,
    'Output Growth' Growth, 'Wage Inflation' Wage
   
!measurement_shocks

    'Measurement Error on Price Inflation' Mp,
    'Measurement Error on Wage Inflation' Mw
 
%

%% Control Linearized and Log-Linerised Variables
%
% By default, all variables are linearized when the first-order solution is
% computed in non-linear models. If you want some variables to be
% log-linearized instead, use the |!log_variables| section. Note how the
% keyword |!all_but| reverses the logic of this section -- all variables
% will be log-linearized except those listed here.
   
!log_variables

    !all_but
    Short, Infl, Growth, Wage
 
%
   
%% Write Model Equations
%
% Each equation must end with a semicolon. As in variable declaration,
% equations also can be annotated with a single-quoted text preceding the
% equation.

!transition_equations

    % Consumers

    P*Lambda =# (1-chi)/(Y - chi*H) !! P*Y*Lambda = 1;
    Lambda = beta*R*Lambda{1} !! beta*R = alpha*pi;
    H = exp(Ey)*alpha*Y{-1} !! H = Y;

    'Wage Phillips Curve' xiw/(eta-1)*(dW/dW{-1} - 1) = ...
      beta*xiw/(eta-1)*(dW{1}/dW - 1 + Ew) ...
      + (eta/(eta-1)*N^psi/(Lambda*W) - 1) ...
      !! eta/(eta-1)*N^psi = Lambda*W;

    % Price of Capital

    Lambda*Pk = beta*Lambda{1}*(Rk{1} + (1-delta)*Pk{1});

    % Supply Side

    'Production Function' Y = A * (N - (1-gamma)*$N)^gamma * k^(1-gamma);
    gamma*Q*Y =# W*(N - (1-gamma)*$N);
    (1-gamma)*Q*Y = Rk*k;

    'Price Phillips Curve' xip/(eta-1)*(dP/dP{-1} - 1) = ...
      beta*xip/(eta-1)*(dP{1}/dP - 1 + Ep) ...
      + (eta/(eta-1)*RMC - 1) !! eta/(eta-1)*Q = P;

    RMC = Q/P !! RMC = (eta-1)/eta;

    % Productivity.
    
    log(dA) = rhoa*log(dA{-1}) + (1-rhoa)*log(alpha) + Ea;
    dA = A/A{-1};

    % Monetary Policy

    log(R) = rhor*log(R{-1}) + (1-rhor)*(log($R) ...
       + kappap*(log(dP{4}) - log(pi)) ...
      + kappan*(N/$N - 1)) + Er
      !! d4P = pi^4;

    % One-Quarter and Four-Quarter Rates of Change

    dP = P/P{-1};
    d4P = P/P{-4};
    dW = W/W{-1};

%
   
%% Write Measurement Equations

!measurement_equations

    Short =  100*(R^4 - 1);
    Infl = 100*((P/P{-1})^4 - 1 + Mp);
    Wage = 100*((W/W{-1})^4 - 1 + Mw);
    Growth = 100*((Y/Y{-1})^4 - 1);
 
%

%% Parameters for Deterministic Trends

!parameters

    Short_, Infl_, Growth_, Wage_

   
%% Write Deterministic Trends on Measurement Variables

!dtrends

    Short += Short_;
    Infl += Infl_;
    Growth += Growth_;
    Wage += Wage_;
   
