package com.example;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class SetUp {
    private JFrame frame;
    private JTextField emailField;
    private JPasswordField passwordField;
    private JRadioButton customerRadio;
    private JRadioButton adminRadio;
    private LoginCallback callback;

    public SetUp(LoginCallback callback) {
        this.callback = callback;
        frame = new JFrame("Login");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(300, 250);
        frame.setLayout(null);

        // Tạo các thành phần
        JLabel emailLabel = new JLabel("Email:");
        emailLabel.setBounds(30, 30, 100, 25);

        emailField = new JTextField();
        emailField.setBounds(130, 30, 130, 25);

        JLabel passwordLabel = new JLabel("Password:");
        passwordLabel.setBounds(30, 70, 100, 25);

        passwordField = new JPasswordField();
        passwordField.setBounds(130, 70, 130, 25);

        customerRadio = new JRadioButton("Customer");
        customerRadio.setBounds(30, 110, 100, 25);
        adminRadio = new JRadioButton("Admin");
        adminRadio.setBounds(130, 110, 100, 25);

        ButtonGroup group = new ButtonGroup();
        customerRadio.setSelected(true);
        group.add(customerRadio);
        group.add(adminRadio);

        JButton loginButton = new JButton("Login");
        JButton registerButton = new JButton("Register");
        loginButton.setBounds(15, 160, 120, 25);
        loginButton.setFocusPainted(false);
        loginButton.addActionListener(new LoginAction());
        registerButton.setBounds(150, 160, 120, 25);
        registerButton.setFocusPainted(false);
        registerButton.addActionListener(e -> {
            RegisterFrame registerFrame = new RegisterFrame(callback);
            registerFrame.setVisible(true);
            frame.dispose();
        });


        frame.add(emailLabel);
        frame.add(emailField);
        frame.add(passwordLabel);
        frame.add(passwordField);
        frame.add(customerRadio);
        frame.add(adminRadio);
        frame.add(loginButton);
        frame.add(registerButton);

    }

    private class LoginAction implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            String email = emailField.getText();
            String password = new String(passwordField.getPassword());
            String userType = customerRadio.isSelected() ? "Customer" : "Admin";
            if (email.isEmpty() || password.isEmpty()) {
                JOptionPane.showMessageDialog(frame, "Email and Password cannot be empty.", "Error",
                        JOptionPane.ERROR_MESSAGE);
            } else {
                try {

                    Connection connection = SQLServerHandle.getConnection();
                    String sql = "SELECT "+userType+"ID FROM "+userType+" WHERE Email = ? AND "+String.valueOf(userType.charAt(0))+"_Password = ?";
                    PreparedStatement preparedStatement = connection.prepareStatement(sql);
                    preparedStatement.setString(1, email);
                    preparedStatement.setString(2, password);
                    ResultSet resultSet = preparedStatement.executeQuery();
                    
                    if (resultSet.next()) {
                        callback.onLoginSuccess(userType,resultSet.getString(1), (resultSet != null));
                        frame.dispose();
                    }
                } catch (Exception ex) {
                    ex.printStackTrace();
                }
            }

        }
    }

 
    // public static void main(String[] args) {
    // SwingUtilities.invokeLater(SetUp::new);
    // }

    public void setVisible(boolean b) {
        frame.setVisible(b);
    }
}