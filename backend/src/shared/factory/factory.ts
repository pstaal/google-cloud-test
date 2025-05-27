export abstract class Factory<T> {
  protected abstract createEntity(overriddenValues: Partial<T>): T;

  public generate(
    count = 1,
    overriddenValues: Partial<T> | Partial<T>[] = {},
  ): T[] {
    if (!Array.isArray(overriddenValues)) {
      overriddenValues = [overriddenValues];
    }

    const result: T[] = [];

    for (let i = 0; i < count; i++) {
      for (const overriddenValue of overriddenValues) {
        result.push(this.createEntity(overriddenValue));
      }
    }

    return result;
  }

  public generateSingle(defaultValues: Partial<T> = {}): T {
    return this.generate(1, defaultValues ?? {})[0];
  }
}