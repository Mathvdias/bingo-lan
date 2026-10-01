package com.nightstudios.bingo;

import androidx.test.platform.app.InstrumentationRegistry;
import org.junit.Test;

import static org.junit.Assert.*;

public class SimpleAndroidTest {
  @Test
  public void useAppContext() {
    // Context of the app under test.
    var context = InstrumentationRegistry.getInstrumentation().getTargetContext();
    assertEquals("com.nightstudios.bingo", context.getPackageName());
  }
}
