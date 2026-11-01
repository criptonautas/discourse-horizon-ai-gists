# Horizon AI Gists

[ENGLISH](README.md) | **ESPAÑOL**

Mantenido por Criptonautas. Sin afiliación ni respaldo de Discourse (Civilized Discourse Construction Kit, Inc.).

Muestra los resúmenes cortos de IA de [discourse-ai](https://meta.discourse.org/t/summarize-gists/340269)
(gists) en las tarjetas de tema del tema [Horizon](https://meta.discourse.org/t/horizon-theme/360486).

| Escritorio | Móvil |
|---|---|
| ![Resúmenes en tarjetas de Horizon, escritorio](docs/screenshots/gists-desktop.png) | ![Resúmenes en tarjetas de Horizon, móvil](docs/screenshots/gists-mobile.png) |

## Por qué

discourse-ai renderiza los resúmenes en dos outlets del núcleo dentro de la celda del
tema. La tarjeta de alto contexto de Horizon reemplaza esa celda, así que en Horizon los
resúmenes nunca aparecen, algo que Discourse considera comportamiento esperado. Este
componente renderiza el resumen en `topic-list-after-title`, el único outlet del núcleo
que conserva la tarjeta.

## Qué hace

- **Tarjetas de alto contexto:** el resumen va bajo el título y reemplaza al extracto.
  Los temas sin resumen conservan su extracto.
- **Tarjetas simples** (listas de temas sugeridos o relacionados): el resumen propio de
  discourse-ai se ubica en la cuadrícula de la tarjeta en lugar de romperla en una columna.
- **Listas de discourse-docs:** un solo texto por fila: el resumen si existe, si no el
  extracto.
- **`gist_hidden_categories`:** categorías que no muestran ni resumen ni extracto, como un
  índice solo de títulos.

### Opcional: tres modos de visualización

Con [Topic Excerpts & AI Gists Button](https://meta.discourse.org/t/topic-excerpts-ai-gists-button/394885)
instalado, los miembros pueden alternar entre **Compacto** (solo títulos), **Extractos** y
**Resúmenes de IA**. Ese botón espera un servicio `excerptState` que no incluye; este
componente aporta uno, así que no lo instales junto a otro componente que defina
`excerptState`. Sin el botón, los resúmenes simplemente se muestran.

## Requisitos

- Discourse 2026.5.0 o posterior.

Los resúmenes solo llegan al navegador cuando discourse-ai permite verlos a quien visita:

- `ai_summarization_enabled` y `ai_summary_gists_enabled` activados.
- `ai_summary_gists_agent` apuntando a un agente cuyos **grupos permitidos** incluyan el
  grupo de quien visita; agrega `everyone` para incluir a visitantes sin sesión. Un agente
  sin grupos oculta los resúmenes a todos, aunque la administración los muestre como
  generados.
- Resúmenes generados: `ai_summary_backfill_maximum_topics_per_hour` mayor que 0.

Compruébalo desde la consola del navegador en `/latest` (un número distinto de cero
significa que los resúmenes están llegando):

```js
fetch("/latest.json").then((r) => r.json()).then((d) =>
  console.log(d.topic_list.topics.filter((t) => t.ai_topic_gist).length)
);
```

## Límites

- **Depende de detalles internos de Horizon** (`.hc-topic-card`, `.--high-context`, la
  cuadrícula de las tarjetas simples). Discourse no da soporte a personalizar las tarjetas
  de Horizon, así que una actualización de Horizon puede romperlo.
- **Ocultar es solo cosmético.** discourse-ai no permite limitar por categoría: los
  resúmenes ocultos se siguen generando y enviando en la lista de temas.
- **No se indexa.** Los resúmenes se renderizan en el cliente; los buscadores reciben la
  vista para rastreadores de Discourse, que incluye extractos pero no resúmenes.
- **Los lectores de pantalla reciben el extracto, no el resumen.** El resumen está dentro
  del encabezado del título de Horizon, así que se les oculta para mantenerlo breve.
- **Queda guardada una preferencia.** El componente fija en `table-ai` la preferencia de
  diseño de discourse-ai de cada navegador, para mostrar los resúmenes por defecto. Quitar
  el componente no la restablece.

## Instalación

**Administración → Apariencia → Temas y componentes → Instalar**, desde la URL de este
repositorio, y luego agrégalo a Horizon.

## Desarrollo

`pnpm install && pnpm lint`. La CI también ejecuta las pruebas QUnit de `test/` y la
especificación de funciones del núcleo. Las notas para colaborar están en [AGENTS.md](AGENTS.md).

## Licencia

MIT. Consulta [LICENSE](LICENSE).

Texto de este README bajo [CC BY-NC-SA 4.0](CC-BY-NC-SA-4.0.txt).
