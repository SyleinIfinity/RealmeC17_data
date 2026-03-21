package com.example;

public interface LoginCallback {
    void onLoginSuccess(String role,String stk, boolean stt);
    void onLoginFailure(String message);
}