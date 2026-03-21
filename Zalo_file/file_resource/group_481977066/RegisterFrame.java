package com.example;

import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Calendar;

import javax.swing.JButton;
import javax.swing.JFrame;
import javax.swing.JLabel;
// import javax.swing.JOptionPane;
import javax.swing.JPasswordField;
import javax.swing.JSpinner;
import javax.swing.JTextField;
// import javax.swing.SwingUtilities;
import javax.swing.SpinnerDateModel;

public class RegisterFrame {
    private JFrame frame;
    private JTextField emailField;
    private JTextField numberField;
    private JPasswordField passwordField;
    private LoginCallback callback;

    public RegisterFrame(LoginCallback callback) {
        this.callback = callback;
        frame = new JFrame("Register");
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setSize(300, 255);
        frame.setLayout(null);

        JLabel emailLabel = new JLabel("Email:");
        emailLabel.setBounds(30, 30, 100, 25);
        emailField = new JTextField();
        emailField.setBounds(130, 30, 130, 25);

        JLabel phoneLabel = new JLabel("Phone: ");
        phoneLabel.setBounds(30, 65, 100, 25);
        numberField = new JTextField(10);
        numberField.setBounds(130, 65, 130, 25);

        JLabel pwLabel = new JLabel("Password: ");
        pwLabel.setBounds(30, 100, 100, 25);
        passwordField = new JPasswordField(10);
        passwordField.setBounds(130, 100, 130, 25);

        JLabel dateLabel = new JLabel("Date of Birth: ");
        dateLabel.setBounds(30, 135, 130, 25);
        Calendar calendar = Calendar.getInstance();
        calendar.add(Calendar.YEAR, -18);
        JSpinner dateSpinner = new JSpinner(
                new SpinnerDateModel(calendar.getTime(), null, null, Calendar.DAY_OF_MONTH));
        JSpinner.DateEditor dateEditor = new JSpinner.DateEditor(dateSpinner, "dd/MM/yyyy");
        dateSpinner.setEditor(dateEditor);
        dateSpinner.setValue(calendar.getTime());
        dateSpinner.setBounds(130, 135, 130, 25);

        JButton loginButton = new JButton("Login");
        JButton registerButton = new JButton("Register");
        registerButton.setBounds(15, 170, 120, 25);
        registerButton.setFocusPainted(false);
        loginButton.setBounds(150, 170, 120, 25);
        loginButton.setFocusPainted(false);
        loginButton.addActionListener(e -> {
            SetUp setup = new SetUp(callback);
            setup.setVisible(true);
            frame.dispose();
        });
        registerButton.addActionListener(new RegiterAction());

        frame.add(dateLabel);
        frame.add(dateSpinner);
        frame.add(emailLabel);
        frame.add(emailField);
        frame.add(phoneLabel);
        frame.add(numberField);
        frame.add(pwLabel);
        frame.add(passwordField);
        frame.add(loginButton);
        frame.add(registerButton);
    }

    public void setVisible(boolean b) {
        frame.setVisible(b);
    }

    private class RegiterAction implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e) {
            // Handle Register Account

        }
    }
}
