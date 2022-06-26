using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class BlurRendererFeature : ScriptableRendererFeature
{
    [SerializeField] Shader m_shader;
    [SerializeField] string m_textureId;
    [SerializeField] private RenderPassEvent m_renderPassEvent = RenderPassEvent.AfterRenderingSkybox;

    private BlurRendererPass m_pass;

    public override void Create()
    {
        m_pass ??= new BlurRendererPass(m_shader, m_textureId, m_renderPassEvent);
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        m_pass.SetRenderTarget(renderer.cameraColorTarget);
        renderer.EnqueuePass(m_pass);
    }
}
