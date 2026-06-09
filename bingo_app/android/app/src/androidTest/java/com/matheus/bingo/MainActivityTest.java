package com.matheus.bingo;

import androidx.test.rule.ActivityTestRule;
import dev.flutter.plugins.integration_test.FlutterTestRunner;
import org.junit.Rule;
import org.junit.runner.RunWith;
import org.junit.Test;

@RunWith(FlutterTestRunner.class)
public class MainActivityTest {
  @Rule
  public ActivityTestRule<MainActivity> rule = new ActivityTestRule<>(MainActivity.class, true, false);
  
  @Test
  public void testIntegration() {
    // Este método é necessário para que o JUnit execute os testes
    // O FlutterTestRunner vai executar os integration tests do Dart
  }
}
