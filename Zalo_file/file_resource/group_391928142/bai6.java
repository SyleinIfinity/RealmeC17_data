package tuan1;

import java.awt.*;
import javax.swing.*;

public class bai6 extends JFrame {
    private JTextArea textArea;

    public bai6() {
        setTitle("Format String");
        setSize(500, 350);
        setDefaultCloseOperation(EXIT_ON_CLOSE);
        setLocationRelativeTo(null);

        // Tạo khu vực nhập văn bản
        JPanel inputPanel = new JPanel(new BorderLayout());
        JLabel titleLabel = new JLabel("Enter String");
        titleLabel.setForeground(Color.RED);
        titleLabel.setFont(new Font("Arial", Font.BOLD, 14));
        textArea = new JTextArea();
        JScrollPane scrollPane = new JScrollPane(textArea);
        inputPanel.add(titleLabel, BorderLayout.NORTH);
        inputPanel.add(scrollPane, BorderLayout.CENTER);
        add(inputPanel, BorderLayout.CENTER);

        // Tạo thanh menu
        JMenuBar menuBar = new JMenuBar();
        setJMenuBar(menuBar);

        // Menu File
        JMenu fileMenu = new JMenu("File");
        JMenuItem exitItem = new JMenuItem("Exit");
        exitItem.addActionListener(e -> System.exit(0));
        fileMenu.add(exitItem);
        menuBar.add(fileMenu);

        // Menu Edit
        JMenu editMenu = new JMenu("Edit");
        JMenuItem clearAllItem = new JMenuItem("Clear All");
        clearAllItem.addActionListener(e -> textArea.setText(""));
        JMenuItem clearSelectionItem = new JMenuItem("Clear Selection");
        clearSelectionItem.addActionListener(e -> textArea.replaceSelection(""));
        JMenuItem ltrimItem = new JMenuItem("LTrim");
        ltrimItem.addActionListener(e -> trimLeft());
        JMenuItem rtrimItem = new JMenuItem("RTrim");
        rtrimItem.addActionListener(e -> trimRight());
        JMenuItem ctrimItem = new JMenuItem("CTrim");
        ctrimItem.addActionListener(e -> trimCenter());
        editMenu.add(clearAllItem);
        editMenu.add(clearSelectionItem);
        editMenu.add(ltrimItem);
        editMenu.add(rtrimItem);
        editMenu.add(ctrimItem);
        menuBar.add(editMenu);

        // Menu Format
        JMenu formatMenu = new JMenu("Format");
        JMenu changeCaseMenu = new JMenu("Change Case");
        JMenuItem sentenceCaseItem = new JMenuItem("Sentence case");
        sentenceCaseItem.addActionListener(e -> changeCase("sentence"));
        JMenuItem lowerCaseItem = new JMenuItem("lowercase");
        lowerCaseItem.addActionListener(e -> changeCase("lower"));
        JMenuItem upperCaseItem = new JMenuItem("UPPERCASE");
        upperCaseItem.addActionListener(e -> changeCase("upper"));
        JMenuItem titleCaseItem = new JMenuItem("Title Case");
        titleCaseItem.addActionListener(e -> changeCase("title"));
        JMenuItem toggleCaseItem = new JMenuItem("tOGGLE cASE");
        toggleCaseItem.addActionListener(e -> changeCase("toggle"));
        changeCaseMenu.add(sentenceCaseItem);
        changeCaseMenu.add(lowerCaseItem);
        changeCaseMenu.add(upperCaseItem);
        changeCaseMenu.add(titleCaseItem);
        changeCaseMenu.add(toggleCaseItem);
        formatMenu.add(changeCaseMenu);
        menuBar.add(formatMenu);

        // Nút chức năng
        JPanel buttonPanel = new JPanel();
        JButton changeCaseButton = new JButton("Change Case");
        changeCaseButton.setBackground(Color.PINK);
        changeCaseButton.addActionListener(e -> showChangeCaseDialog());
        JButton exitButton = new JButton("Exit");
        exitButton.setBackground(Color.PINK);
        exitButton.addActionListener(e -> System.exit(0));
        buttonPanel.add(changeCaseButton);
        buttonPanel.add(exitButton);
        add(buttonPanel, BorderLayout.SOUTH);
    }

    private void trimLeft() {
        String selectedText = textArea.getSelectedText();
        if (selectedText != null) {
            textArea.replaceSelection(selectedText.replaceAll("^\\s+", ""));
        }
    }

    private void trimRight() {
        String selectedText = textArea.getSelectedText();
        if (selectedText != null) {
            textArea.replaceSelection(selectedText.replaceAll("\\s+$", ""));
        }
    }

    private void trimCenter() {
        String selectedText = textArea.getSelectedText();
        if (selectedText != null) {
            textArea.replaceSelection(selectedText.replaceAll("\\s{2,}", " "));
        }
    }

    private void changeCase(String caseType) {
        String selectedText = textArea.getSelectedText();
        if (selectedText != null) {
            switch (caseType) {
                case "sentence":
                    textArea.replaceSelection(Character.toUpperCase(selectedText.charAt(0)) + selectedText.substring(1).toLowerCase());
                    break;
                case "lower":
                    textArea.replaceSelection(selectedText.toLowerCase());
                    break;
                case "upper":
                    textArea.replaceSelection(selectedText.toUpperCase());
                    break;
                case "title":
                    textArea.replaceSelection(toTitleCase(selectedText));
                    break;
                case "toggle":
                    textArea.replaceSelection(toggleCase(selectedText));
                    break;
            }
        }
    }

    private String toTitleCase(String text) {
        String[] words = text.split("\\s");
        StringBuilder titleCase = new StringBuilder();
        for (String word : words) {
            if (word.length() > 0) {
                titleCase.append(Character.toUpperCase(word.charAt(0))).append(word.substring(1).toLowerCase()).append(" ");
            }
        }
        return titleCase.toString().trim();
    }

    private String toggleCase(String text) {
        StringBuilder toggled = new StringBuilder();
        for (char c : text.toCharArray()) {
            if (Character.isUpperCase(c)) {
                toggled.append(Character.toLowerCase(c));
            } else {
                toggled.append(Character.toUpperCase(c));
            }
        }
        return toggled.toString();
    }

    private void showChangeCaseDialog() {
        JDialog dialog = new JDialog(this, "Change Case", true);
        dialog.setSize(300, 250);
        dialog.setLayout(new BorderLayout());
        dialog.setLocationRelativeTo(this);
    
        JPanel radioPanel = new JPanel(new GridLayout(5, 1, 5, 5));
        ButtonGroup group = new ButtonGroup();
        JRadioButton sentenceCase = new JRadioButton("Sentence case", true);
        JRadioButton lowerCase = new JRadioButton("lowercase");
        JRadioButton upperCase = new JRadioButton("UPPERCASE");
        JRadioButton titleCase = new JRadioButton("Title Case");
        JRadioButton toggleCase = new JRadioButton("tOGGLE cASE");
    
        group.add(sentenceCase);
        group.add(lowerCase);
        group.add(upperCase);
        group.add(titleCase);
        group.add(toggleCase);
    
        radioPanel.add(sentenceCase);
        radioPanel.add(lowerCase);
        radioPanel.add(upperCase);
        radioPanel.add(titleCase);
        radioPanel.add(toggleCase);
    
        JPanel buttonPanel = new JPanel();
        JButton okButton = new JButton("OK");
        okButton.setBackground(Color.PINK);
        okButton.addActionListener(e -> {
            if (sentenceCase.isSelected()) changeCase("sentence");
            if (lowerCase.isSelected()) changeCase("lower");
            if (upperCase.isSelected()) changeCase("upper");
            if (titleCase.isSelected()) changeCase("title");
            if (toggleCase.isSelected()) changeCase("toggle");
            dialog.dispose();
        });
    
        JButton cancelButton = new JButton("Cancel");
        cancelButton.setBackground(Color.PINK);
        cancelButton.addActionListener(e -> dialog.dispose());
    
        buttonPanel.add(okButton);
        buttonPanel.add(cancelButton);
    
        dialog.add(radioPanel, BorderLayout.CENTER);
        dialog.add(buttonPanel, BorderLayout.SOUTH);
    
        dialog.setVisible(true);
    }
    

    public static void main(String[] args) {
        SwingUtilities.invokeLater(() -> new bai6().setVisible(true));
    }
}